from collections import defaultdict

import boto3
from botocore.exceptions import ClientError

# AWS services and their list functions
SERVICE_RESOURCE_FUNCTIONS = {
    "ec2": [
        ("describe_instances", "Reservations"),
        (
            "describe_security_groups",
            "SecurityGroups",
            lambda sg: not sg.get("GroupName", "").startswith("default"),
        ),
        ("describe_vpcs", "Vpcs", lambda vpc: not vpc.get("IsDefault", False)),
        (
            "describe_subnets",
            "Subnets",
            lambda subnet: not subnet.get("DefaultForAz", False),
        ),
        ("describe_internet_gateways", "InternetGateways"),
        (
            "describe_route_tables",
            "RouteTables",
            lambda rt: not any(
                assoc.get("Main", False) for assoc in rt.get("Associations", [])
            ),
        ),
    ],
    "s3": [
        ("list_buckets", "Buckets"),
    ],
    "rds": [
        ("describe_db_instances", "DBInstances"),
    ],
    "lambda": [
        ("list_functions", "Functions"),
    ],
    "cloudformation": [
        (
            "describe_stacks",
            "Stacks",
            lambda stack: stack["StackStatus"] != "DELETE_COMPLETE",
        ),
    ],
    "iam": [
        ("list_roles", "Roles"),
    ],
}


def get_all_regions(service="ec2"):
    ec2 = boto3.client(service)
    response = ec2.describe_regions(AllRegions=True)
    return [
        r["RegionName"]
        for r in response["Regions"]
        if r["OptInStatus"] in ("opt-in-not-required", "opted-in")
    ]


def count_resources():
    result = defaultdict(lambda: defaultdict(int))
    regions = get_all_regions()

    for service_name, functions in SERVICE_RESOURCE_FUNCTIONS.items():
        for region in regions:
            try:
                client = (
                    boto3.client(service_name, region_name=region)
                    if service_name != "s3" and service_name != "iam"
                    else boto3.client(service_name)
                )
                for func_name, result_key, *optional_filter in functions:
                    try:
                        paginator = client.get_paginator(func_name)
                        page_iterator = paginator.paginate()
                        count = 0
                        for page in page_iterator:
                            items = page.get(result_key, [])
                            if optional_filter:
                                items = list(filter(optional_filter[0], items))
                            count += len(items)
                        result[region][f"{service_name}:{func_name}"] = count
                    except ClientError as e:
                        print(f"Error with {service_name}:{func_name} in {region}: {e}")
            except Exception as e:
                print(f"Could not connect to {service_name} in {region}: {e}")

    return result


if __name__ == "__main__":
    from pprint import pprint

    pprint(dict(count_resources()))
