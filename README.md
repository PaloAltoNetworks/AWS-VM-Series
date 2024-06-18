# aws-panw-vmseries-cft-deployment

This GitHub repository contains CloudFormation templates designed to deploy a lab environment featuring Palo Alto's VM-Series firewall integrated with AWS Gateway Load Balancer. The primary goal of this lab is to provide hands-on experience in setting up and configuring network security measures to protect digital assets. The lab aims to simulate various network security scenarios and provides a structured environment for users to practice configuring and managing network security policies.

The lab consists of multiple use cases, each addressing specific network security tasks and validations. In this lab we are deploying a single instance of VM-Series firewall and not using autoscale service.

**Duration**: It will take approximately 2 hours to successfully complete this lab.

**Note**:  After completion of lab please make sure to run the **cleanup steps** mentioned towards the end of this guide to remove the resources, even if you are not able to complete it please execute the cleanup to remove all the resources.

## Outline

<br />
<p><img src="https://aws-jam-challenge-resources.s3.amazonaws.com/panw-vmseries-gwlb/detailed-start.png" alt="Full Starting Diagram with Route Tables" width="1500" /></p>
<br />

- aws-panw-gwlb-cfn-root.yaml. This is the root stack that will be deployed. The other template files are nested from this one.


You can set up this environment in the following way:

### Rapid S3 Setup

**Note:** You will need access to AWS CloudShell for this mode of setup.

1. Login to the AWS Console and change to the region of your choosing. Supported regions are:
    - eu-north-1
    - eu-west-1
    - us-east-1
    - us-east-2
    - us-west-1
    - us-west-2
2. Open AWS CloudShell, wait for the CLI prompt to show up.
3. Clone the github repository.
```
git clone https://github.com/PaloAltoNetworks/AWS-VM-Series.git && cd AWS-VM-Series
```
4. Run the setup command.
```
chmod +x setup-cft.sh
./setup-cft.sh
```

Once the script completes execution, you should be able to see the output as shown below.
```
Setup completed successfully. Please proceed to CFT deployment.
Please use the below Template URL for CFT deployment.
TEMPLATE_URL = https://panw-aws-resources-506b9ea8-ce65-4416-8f5d-288991b33a30.s3.us-east-1.amazonaws.com/panw-vmseries-gwlb/aws-panw-gwlb-cfn-root.yaml
```
5. Please create a new EC2 key pair in the region where you are going to deploy the setup script and once you have uploaded the setup script please rename the EC2 key pair and provide the name of the key-pair that you have generated


## Please go through the following cases in order to run the Use Cases


## Use Case 1: Inspect outbound traffic using VM Series

In this Use Case we will be redirecting outbound traffic from the **Beer Store Data Database Server** to the **Palo Alto Networks** firewall for inspection. This involves AWS routing adjustments and verifying traffic logs on the firewall. Read the following in order to run the Use Case 1:
## Task

**Step 1**- In this step we will Update AWS routing to redirect the Beer Store Data Database Server outbound traffic for inspection by VM-Series through the "Transit Gateway". Please go through the follwoing steps:

  1: In this step we will check the VPC Route Table to check if the Route Tables of the Beer Store Data VPC is pointing to 
     the correct resource

  2: The Traffic will not be shown in the firewall at first, to see the traffic in the Firewall monitoring. Please do the 
     following:

  1. Login into the AWS console
  2. Go to VPC
  3. Select in filter by VPC field the "Beer Store Data VPC"
  4. Next, go to route tables and select the "Beer Store Data Private route table"
  5. In the route table click on routes (see below)
<br />
<p><img src="https://aws-jam-challenge-resources.s3.amazonaws.com/panw-vmseries-gwlb/task1-routes.png" /></p>
<br />
  6. Click Edit routes and do the following changes:
        
  1. Remove the route 10.0.0.0/8 -> Target TGW
  2. Change the route 0.0.0.0/0 -> TGW
  3. Click Save

7. Once you made the changes your route should look like the example below
<br />
<p><img src="https://aws-jam-challenge-resources.s3.amazonaws.com/panw-vmseries-gwlb/task1-clue2-new.png" /></p>
<br />

**Step 2**- Now login to the firewall. Go through the following steps:

  - Identify the Elastic IP (Security VM-Series Management) of the EC2 Instance named "Security VM-Series" to find the server's private IP.
    1. On the AWS Console go to EC2
    2. On the EC2 Dashboard click on Instances
    3. The following EC2 instances are used by the lab:
       - Beer Store Data Database
       - Beer Store Frontend Webserver
       - Security VM-Series (Palo Alto Networks Firewall)


  - Open a browser window and navigate to https://("Security VM-Series-EIP")
    - Login with the following credentials:
    - Username: admin
    - Password: Pal0Alt0@123
<br />

**Step 3**- Now we will do the following steps in order to run the attack:
- Once you made the appropriate changes in the AWS routing you can log into the **Beer Store Data Database Server** via the SSM service and test with the **curl** command if the EC2 instance has internet access.
  - example curl command **sudo curl www.google.de**
  - To Login into the Beer Store Data Database Server:
    - Use the Session Manager to log into the Server
    - The name of the VM is "Beer Store Data Database"

- If the curl command isn't working in the **Beer Store Data Database Server**, check the Palo Alto Networks Firewall Monitor Logs to see which application is now blocked from the Firewall. 

- You should see the following example log in the firewall monitoring. By adding the following filter **( zone.src eq internal ) and ( zone.dst eq external )** into the Monitor Logs filter bar.<br />
   Some fields in the example log were removed.
<p><img src="https://aws-jam-challenge-resources.s3.amazonaws.com/panw-vmseries-gwlb/task1-deny2.png" alt="VPC Logs" width="1500" /></p>
<br />

**Step 4**- Check the "Firewall Monitor" traffic logs to verify if you can see any traffic from the Beer Store Data Database Server. To see the Traffic Logs inside the firewall:
- Login into the firewall
- Inside the firewall navigate to Monitor -> Traffic
- See the following picture as an example <p><img src="https://aws-jam-challenge-resources.s3.amazonaws.com/panw-vmseries-gwlb/example.png" alt="Monitor Logs" width="1500" /></p>
- In the :Monitor: Traffic" window change the refresh timer from **Manual** to **10 seconds** by clicking on the dropdown field on the top right as the picture below shows
<p><img src="https://aws-jam-challenge-resources.s3.amazonaws.com/panw-vmseries-gwlb/task1-10.png" alt="Monitor Logs" width="1500" /></p>

 <br />
<br />

This is the end of first Use Case.
<br />

## Use Case 2: Inspect east-west traffic using VM-Series

In this Use Case we will have VM-Series firewall inspect east-west traffic between the **Beer Store Data Database Server** and the **Beer Store Frontend Webserver**. As a part of this task we will update the AWS routing and also check the firewall logs. Read the following in order to run the Use Case 2:
## Task

1. As the first step let's check the traffic between the Beer Store Data Database Server and the Beer Store Frontend Webserver. You can add the following filter into the Firewall Monitor **( zone.src eq internal ) and ( zone.dst eq internal )**
2. There should not be logs seen on the firewall, so let's update the AWS routing. Please go through the following steps:

**Step 1**: To make changes in the AWS routing we will do the following:
  1. Login into the AWS console
  2. Go to VPC Services and select under Transit Gateways the Transit gateway route tables
<br />
<p><img src="https://aws-jam-challenge-resources.s3.amazonaws.com/panw-vmseries-gwlb/task2-tgw-rt.png" /></p>
<br />

  3. Select the Spoke TGW Route Table
  4. In the Route table click on Propagations
<br />
<p><img src="https://aws-jam-challenge-resources.s3.amazonaws.com/panw-vmseries-gwlb/task2-tgw2.png" /></p>
<br />

  5. Select each propagations one by one and click delete propagations. Repeat it until both are deleted.
  6. Your TGW Route table should looks like the following after the deletion
<br />
<p><img src="https://aws-jam-challenge-resources.s3.amazonaws.com/panw-vmseries-gwlb/task2-clue1.png" /></p>
<br />

**Step 2**: To find the logs inside the "Firewall: Monitor":
  1. Log into the Palo Alto Networks VM-Series Firewall
  2. Go to Monitor -> Traffic
<br />
<p><img src="https://aws-jam-challenge-resources.s3.amazonaws.com/panw-vmseries-gwlb/example.png" /></p>

<br />

Note: The attack is being automatically generated.

  3. In the Filter field paste the the following filter ( zone.src eq internal ) and ( zone.dst eq internal ) and ( app eq ssh )
<br />
<p><img src="https://aws-jam-challenge-resources.s3.amazonaws.com/panw-vmseries-gwlb/task2-filter.png" /></p>
<br />

**Step 3**:
  1. In the Monitor logs have a look at the column "TO PORT".
<br />
<p><img src="https://aws-jam-challenge-resources.s3.amazonaws.com/panw-vmseries-gwlb/task2-clue3.png" /></p>
<br />

  2. Once you made the appropriate changes in AWS check if can see now traffic between the **Beer Store Data Database Server** and the **Beer Store Frontend Webserver** by typing the following filter in the "Firewall: Monitor" **( zone.src eq internal ) and ( zone.dst eq internal )**
   
  3. You should be able to see the following Monitor Logs inside the Firewall
<p><img src="https://aws-jam-challenge-resources.s3.amazonaws.com/panw-vmseries-gwlb/task2-ssh-new.png" alt="SSH Logs" width="1500" /></p>
<br />

This is the end of second Use Case.
<br />

## Use Case 3: Inspect inbound traffic using VM-Series

In this Use Case the VM-Series firewall will inspect inbound traffic towards the **Beer Frontend VPC**. As a part of this task we will be redirecting traffic, checking logs, identifying vulnerabilities, and updating firewall settings to block or reset malicious traffic. Read the following in order to run the Use Case 3:

## Task

1. You realized that you have no inbound inspection on the Beer Store by looking into the "Firewall: Monitor" logs and adding the following filter  **(( zone.src eq frontend ) and ( zone.dst eq frontend )) or (( zone.src eq external ) and ( zone.dst eq internal ))**.

2. You should now redirect the traffic from the Beer Frontend VPC to the Firewall. Please go through the following steps:

    1. Login into the AWS console
    2. Go to VPC
    3. Select in Filter by VPC field the "Beer Store Frontend VPC"
    4. As next go to Route Tables and select the Beer Store Frontend Public route table
    5. In the route table click on Routes (see below)
  
<p><img src="https://aws-jam-challenge-resources.s3.amazonaws.com/panw-vmseries-gwlb/task3-clue1-pup-rt.png" /></p>

  vi. Click Edit routes and do the following changes:
  - Change the route 0.0.0.0/0 -> Gateway Load Balancer Endpoint
  - Click Save


  vii. Once you made the changes your routle should looks like the example below
<br />
<p><img src="https://aws-jam-challenge-resources.s3.amazonaws.com/panw-vmseries-gwlb/task3-clue1.png" /></p>
<br />

3. Now after you redirect inbound traffic through the firewall, you should connect to the **Beer Store Frontend Webserver** (HTTP) over the Public IP. You should be able to see the following Webpage. This is the entrypoint to the Log4j Attack. The attack is being automatically generated, you do not need to authenticate to the beer store frontend before proceeding to the next step
   <p><img src="https://aws-jam-challenge-resources.s3.amazonaws.com/panw-vmseries-gwlb/beerstore.png" alt="Beer Store" width="500" /></p>
   In the "Firewall: Monitor" logs, you should see the following log by entering the filter ( addr.src in YOUR-PIP ). Replace "YOUR-PIP" with your local Public IP (Logs can take up to 1 min to be shown in the Monitor) <br />
   <p><img src="https://aws-jam-challenge-resources.s3.amazonaws.com/panw-vmseries-gwlb/task3-logs.png" alt="Logs" width="1000" /></p>
 In case you still don't see any traffic logs, check the Internet Edge route table or do the following:
 1. Login into the AWS console
 2. Go to VPC
 3. Select in Filter by VPC field the "Beer Store Frontend VPC"
 4. As next go to Route Tables and select the Beer Store Frontend IGW Edge route table
 5. In the route table click on Routes (see below)
 <br />
 <p><img src="https://aws-jam-challenge-resources.s3.amazonaws.com/panw-vmseries-gwlb/task3-clue2-igw-rt.png" /></p>
 <br />
 6. Click "Edit routes" and do the following change:
 - Add the route 10.1.2.0/24 -> Gateway Load Balancer Endpoint
 - Click Save
 <p><img src="https://aws-jam-challenge-resources.s3.amazonaws.com/panw-vmseries-gwlb/task3-clue2-igw-rt2.png" /></p>
 7. Once you made the changes your routle should looks like the example below
 <br />
 <p><img src="https://aws-jam-challenge-resources.s3.amazonaws.com/panw-vmseries-gwlb/task3-clue2.png" /></p>
 <br />

4. Next we will check the Firewall Monitor Threat logs, to see if any unexpected behaviour is happening. In the Threat Logs, you can see some **Log4j** Attacks. But for some reason, the Firewall isn't blocking them, just alerting. See the picture below as an example.
   <p><img src="https://aws-jam-challenge-resources.s3.amazonaws.com/panw-vmseries-gwlb/alert-log4j-new.png" alt="alert" width="1000" /></p>
   
5. Now you have to change/update the Threat Profile on the Security Policy to block/reset the vulnerable traffic. To perform the change on the Security Policy follow the instructions below:
   
   1. On the Firewall tab on the browser, navigate to the Policies tab, and select Secuirty on the left pane
   <p><img src="https://aws-jam-challenge-resources.s3.amazonaws.com/panw-vmseries-gwlb/pol1.png" width="1000" /></p>
   
   2. Now you can see all the Security rules. Click on the Rule "Allow inbound" frontend rule, and a new window will open
   <p><img src="https://aws-jam-challenge-resources.s3.amazonaws.com/panw-vmseries-gwlb/pol2.png" width="1000" /></p>
   
   3. On the new window click on "Actions" tab
   <p><img src="https://aws-jam-challenge-resources.s3.amazonaws.com/panw-vmseries-gwlb/pol3.png" width="500" /></p>
   
   4. On the "Profile Setting" section you can see that under "Vulnerability Protection",the "alert" profile is selected. That profile will only alert and not block or reset any communication.
   <p><img src="https://aws-jam-challenge-resources.s3.amazonaws.com/panw-vmseries-gwlb/pol4.png" width="500" /></p>
   
   5. Change the "Vulnerability Protection" from "alert" to "strict".
   <p><img src="https://aws-jam-challenge-resources.s3.amazonaws.com/panw-vmseries-gwlb/pol5.png" width="500" /></p>
   
   6. Click "OK", and the window will close automatically.

   7. Next, we have to commit the changes you made to the firewall. Click on the **Commit** button in the top right corner.
   <p><img src="https://aws-jam-challenge-resources.s3.amazonaws.com/panw-vmseries-gwlb/pol6.png" width="500" /></p>

   8. A new window will open. Here you will have to click on "Commit" button
   <p><img src="https://aws-jam-challenge-resources.s3.amazonaws.com/panw-vmseries-gwlb/pol7.png" width="500" /></p>
   
   9. Wait for "Status Complete" and "Result Successful" and close the Window
   <p><img src="https://aws-jam-challenge-resources.s3.amazonaws.com/panw-vmseries-gwlb/pol8.png" width="500" /></p>
   
6. After changing the **Vulnerability Protection** Profile from **alert** to **strict** you should see the following logs under the **Threat section** of the logs:
   <p><img src="https://aws-jam-challenge-resources.s3.amazonaws.com/panw-vmseries-gwlb/blocked-log4j-new.png" width="1000" /></p>
<br />
<br /> 

- After you make the appropriate changes in AWS routing and on the Palo Alto Networks Firewall  it should have successfully blocked the attack to the **Beer Store Frontend Webserver** and you should be able to see a **reset-both** log entry in the Palo Alto Networks Monitor Logs -> Threat.
<br />
<br />

This is the end of third Use Case.
<br />

## Summary
We have completed this lab and we observed how VM Series firewall can be deployed in AWS environment to inspect inbound and east-west flow and inspect the traffic.

## Cleanup Steps
Once you have completed the lab successfully,  follow the following steps for the cleanup:

Go to the AWS Floudformation service and delete the root stack which you had deployed initially using the URL, refer the following steps:

   1. Go to the AWS CloudFormation service and  select the stack(stack name) that was deployed
![Screenshot (181)](https://github.com/AfrahAyub/aws-vmseries-with-gwlbe/assets/93593501/d4ca515c-d765-4109-a51f-a41224c40c9a)
   2. Click on **Delete**
![Screenshot (182)](https://github.com/AfrahAyub/aws-vmseries-with-gwlbe/assets/93593501/951c7365-8f29-41bd-84cd-cbb3eb714da1)
**Note**: it will take approximately 10-15 minutes for the stack to get deleted.
   3. Once the stack is deleted go to the AWS Cloudshell, select Actions and select Delete AWS CloudShell home directory option
![Screenshot (183)](https://github.com/AfrahAyub/aws-vmseries-with-gwlbe/assets/93593501/de107f6b-2123-4b66-b443-9bc20bde2113)





In case you get a message that says: "DELETE_FAILED" for the test-CombinedStack and test-SecurityStack, follow the following steps

**Note**: the name of the stack deployed here is "test", please select the stackname that you have deployed to delete the nested stack

1. Select the test-CombinedStack
![Screenshot (184)](https://github.com/AfrahAyub/aws-vmseries-with-gwlbe/assets/93593501/86faf4c6-7cd6-4268-84a0-157b51a95e10)
2. Click on **Delete**
![Screenshot (185)](https://github.com/AfrahAyub/aws-vmseries-with-gwlbe/assets/93593501/e04e4f4d-2704-44d2-96d1-9c0c6ee39e12)
3. Once the test-CombinedStack is deleted, Select test-SecurityStack 
![Screenshot (187)](https://github.com/AfrahAyub/aws-vmseries-with-gwlbe/assets/93593501/52802da9-8563-46be-a303-229bb1a9e0aa)
4. Click on **Delete**
![Screenshot (188)](https://github.com/AfrahAyub/aws-vmseries-with-gwlbe/assets/93593501/7e6db6ce-7c37-4e11-a71d-469de3e404b0)
5. Finally select the test-stack 
![Screenshot (189)](https://github.com/AfrahAyub/aws-vmseries-with-gwlbe/assets/93593501/b3d171f7-a74f-434a-80df-1e9bca73ccad)
6. Click on **Delete**
![Screenshot (190)](https://github.com/AfrahAyub/aws-vmseries-with-gwlbe/assets/93593501/c8c51126-ba7c-47ee-88f7-67dac26c6980)
7. Now go to the VPC section and check if all the VPCs are deleted, if not then Select the VPC and click **Delete**
![Screenshot (192)](https://github.com/AfrahAyub/aws-vmseries-with-gwlbe/assets/93593501/b624ac57-655a-40df-bad4-50df0c6c980f)
![Screenshot (193)](https://github.com/AfrahAyub/aws-vmseries-with-gwlbe/assets/93593501/966d965d-78a7-41ab-86ef-347cecf798e4)



