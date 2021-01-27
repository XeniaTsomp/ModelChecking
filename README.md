# Quantitative Model Checking for Assessing the Energy Impact of a MITM Attack on EPONs
This is a model checking approach of an Ethernet Passive Optical Network (EPON) under a MITM attack on an energy-efficient mechanism. It is built in Prism model checker as a CTMC model. 
The modules of the OLT and an ONU along with their queues are modeled to represent the OLT-ONU communication in no attack case senario.
Then, the module of the attacker is added to represent the MITM attack.

# Purpose
We use probabilistic model checking to:       
<details>
           <summary>represent the OLT-ONU communication under EPON specifications, as well as, the energy mechanism circumvention.</summary>
</details> 
<details>
           <summary>quantitatively evaluate the impact of a fake Optical Line Terminal (OLT) attacking an EPON energy-efficiency mechanism using probabilistic model checking.</summary>
</details>
         
# Methodology
The PRISM model checker is used for the design and analysis of the proposed EPON_MITM Continuous-Time Markov Chain (CTMC) model.
<details>
<summary>Model checking verifies the property P=? [F≤C0  finish] which provides the probability that all packets have been transmitted and received successfully.</summary>
</details>
<details>
<summary>Cumulative reward properties of the form R~r [C≤ t] are used to evaluate the impact of the attack on the energy-efficiency mechanism.</summary>
</details>

### Message exchange of the energy-efficient mechanism: 
When the OLT has no traffic in its queue it sends a sleep request to the ONU. If the ONU has no upstrean traffic in its queue, it accepts the sleep request, sends an ack message to the OLT and turns to sleep mode.
Otherwise, if the ONU has upstream traffic in its queue, it sends a nack message and remains active until a new sleep message is sent by the OLT.

### MITM attack on the message exchange of the energy-efficient mechanism: 
The attacker intervens to the message exchange of the energy-efficient mechanism, intercepts the OLT's sleep requests and replies to the OLT with a nack message for each request. Hence, the ONU remains active though its queue is empty.  

### Properties specification: 
A number of properties are implemented to the model to derive the quantitative results in the epon.pctl file.  

# Run the code
 Steps :
         
         1. Install the Prism model checker
         
         2. Open the CTMC model
         
         3. Open the properties file
         
         4. Run the expiriments

### 1. Prism model checker Installation
PRISM is a free and open source software. You can download the tool for free from the following link https://www.prismmodelchecker.org/download.php. 

### 2. Open the CTMC model
There are two files in the code folder which correspond to non-attack and attack cases of the CTMC model. To run the CTMC model, you have to select from the code folder the file "DownUpStreams_Noattack.pm" to take the results of non-attack case scenario or the file "DownUpStreams_Attack.pm" to take the results of the attack case scenario. Follow the path "Model-> Open model" from the Prism menu bar to open the selected file.

### 3. Open the Properties' file
Select the epon.pctl file from the code folder to show the properties' list. Follow the path "Properties-> Open properties list" from the Prism menu bar to open the selected file.

### 4. Run the Experiments
To derive the quantitative results open the files of the model and run expiriments by using some properties. A number of constants have to be defined according to the results that the user want to derive.

##### Proof-of-concept results
To take the proof-of-concept results in downstream traffic for non-attack and attack cases with intervention rate 0.5 and 0.99 run expiriments using the property P =? [F<=C0 finish]. 

To take the quantitative results of the non-attack case scenario open the models' file "DownUpStreams_Noattack.pm" and the properties' file "epon.pctl". Select the "Properties" tab and right click on the specific property P =? [F<=C0 finish] from the presented list. Select the choice "New experiment" to run the property. A new window opens where the models' constants have to be defined. Use the defined values of the following query: "Which is the probability that 1000 downstream packets will be transmitted by the OLT and received successfully by the ONU within 100 ms when packet arrival rate varies from 0.2 x 10^2 to 1 x 10^2 packets/ms, the service rate is 1 and no upstream traffic exists?". The arrival rate of upstream can be set to any value since the downstream traffic is examined, but the constants of listening and sleep periods are set at 8ms and 20ms, respectively. The results can be calculated and simultaneously plotted in a graph by clicking the box of "Create Graph" at the same window in order to be examined easily by the user. An example of the way that you can define the constants of model is shown at the following image. 

<img src="images/down.png" width=350>

Then, open the prism software again and open the models' file of the attack case scenario "DownUpStreams_Attack.pm" to run the same experiment as described before. The only thing that the user has to take care of is the intervention rate, which the reader has to set it up manually at the ONU module of the models' code. Hence, if the user wants to take results for the intervention rate of 0.5 where the attacker intercepts the half number of sleep requests, the user has to set this value at the constant rfk and in line 196 of the code at the ONU module. But if the user wants to take the results for the worst-case scenario where the intervention rate is 0.99 and the attacker intercepts almost the total number of sleep requests then, the user has to set the value 0.99 at the constant and the value 0.01 at the ONU module in line 196.       

##### Sleep requests, ack messages and energy saving
To calculate the percentage of sleep requests acceptance, the number of sleep requests and ack messages have to be derived using the properties of R{“sleep”}=? [C≤C0] and R{“ack”}=? [C≤C0]. 

For the non-attack scenario, open the models' file "DownUpStreams_Noattack.pm" and the properties' file "epon.pctl". Select the "Properties" tab and right click on the specific property R{“sleep”}=? [C≤C0] from the presented list. Select the choice "New experiment" to run the property. A new window opens where the models' constants have to be defined. Use the defined values of the following query: "Which is the expected number of sleep request messages sent by the OLT within 100 ms when 2000 packets are transmitted in both directions, downstream packet arrival rate varies from 0.2 x 10^2 to 1 x 10^2 packets/ms, upstream arrival rate is fixed at 0.7×10^2 and the service rate is 1? ". The constants of listening and sleep periods are set at 8ms and 20ms, respectively. The results can be calculated and simultaneously plotted in a graph by clicking the box of "Create Graph" at the same window in order to be examined easily by the user.

According to the aformentioned example, the user has to take the results that are related to the query: " Which is the expected number of ack response messages sent by the ONU" running the experiment for the property R{“ack”}=? [C≤C0] and using the above values.   

Correspondigly, the user can measure the energy saving by running experiments that are related to the query: " Which is the expected energy saving" for the property R{“energy saving”}=? [C≤C0] and using the values of the above example where 2000 packets are transmitted in both directions, downstream packet arrival rate varies from 0.2 x 10^2 to 1 x 10^2 packets/ms, upstream arrival rate is fixed at 0.7×10^2 and the service rate is 1 and listening and sleep periods are set at 8ms and 20ms, respectively. 

For the attack case scenario open the prism software again and open the models' file "DownUpStreams_Attack.pm" to run the same experiments as described before, but taking care of the definition of the intervention rate value as the reader did at proof-of-concept results. 

# Contribution
Anyone is welcome to use the source code. We welcome any contributions to the EPON-MITM attack model development through pull requests on GitHub.
