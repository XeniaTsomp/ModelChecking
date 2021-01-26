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
The PRISM model checker is used for the design and analysis of the proposed EPONMITM Continuous-Time Markov Chain (CTMC) model.
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
The attacker intervens to the message exchange of the energy-efficient mechanism, intercepts the OLT's sleep requests and replies to the OLT with a nack message for each requests. Hence, the ONU remains active though its queue is empty.  

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
There are two files in the code folder which correspond to non-attack and attack cases of the CTMC model. To run the CTMC model, you have to select from the code folder the file "DownUpStreams_Noattack.pm" to take the results of non-attack case scenario or the file "DownUpStreams_Attack.pm" to take the results of the attack case scenario. Follow the path "Model-> Open model" to open the selected file.

### 3. Open the Properties file
At this step select the epon.pctl file from the code folder to show the properties list. Follow the path "Properties-> Open properties list" to open the selected file.

### 4. Run the Expiriments
To derive the quantitative results you have to run some expiriments by using some properties. A number of constants have to be defined according to the results that you want to derive.

For example, if you want to derive the proof-of-concept results in downstream traffic for non-attack and attack case with intervention rate 0.5 and 0.99 you have to run expiriments using the property P =? [F<=C0 finish]. 

to find the probability that 1000 downstream packets will be transmitted by the OLT and received successfully by the ONU within 100 ms when packet arrival rate varies from 0:2 x 102 to 1 x 10^2 packets/ms, the service rate is 1 and no upstream traffic exists.  

An example of downstream traffic is presented at the following image.
<img src="images/downstream no attack.png">
# Contribution
We welcome any contributions to the EPON-MITM attack model development through pull requests on GitHub.
