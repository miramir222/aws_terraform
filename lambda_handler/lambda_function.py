import boto3


def lambda_handler(event, context):
    aws_access_key_id = 'xxx'
    aws_secret_access_key = 'xxx'
    aws_region = 'xxx'

    ec2 = boto3.client('ec2', region_name=aws_region,
                       aws_access_key_id=aws_access_key_id,
                       aws_secret_access_key=aws_secret_access_key)

    instance_name_keyword = "test"
    instances = ec2.describe_instances()

    for reservation in instances['Reservations']:
        for instance in reservation['Instances']:
            for tag in instance.get('Tags', []):
                if tag['Key'] == 'Name' and instance_name_keyword in tag['Value']:
                    instance_id = instance['InstanceId']
                    instance_state = instance['State']['Name']
                    if instance_state in ['terminated', 'stopped']:
                        print(f"Instance {instance_id} is already Terminated Or Stopped.")
                        continue
                    ec2.stop_instances(InstanceIds=[instance_id])
                    print(f"Stopping instance {instance_id}")

    return {
        'statusCode': 200,
        'body': 'EC2 instances stopped successfully.'
    }
