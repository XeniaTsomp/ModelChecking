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
To derive the quantitative results you have to open the files of the model and run some expiriments by using some properties. A number of constants have to be defined according to the results that you want to derive.

For example, if you want to derive the proof-of-concept results in downstream traffic for non-attack and attack case with intervention rate 0.5 and 0.99 you have to run expiriments using the property P =? [F<=C0 finish]. 

First, open the file of the non-attack case scenario "DownUpStreams_Noattack.pm" and the properties' file "epon.pctl". To take the quantitative results of the non-attack case scenario you have to use the defined values in Query 1 and find the probability that 1000 downstream packets will be transmitted by the OLT and received successfully by the ONU within 100 ms when packet arrival rate varies from 0.2 x 10^2 to 1 x 10^2 packets/ms, the service rate is 1 and no upstream traffic exists. The parameters of listening and sleep periods are set at 8ms and 20ms, respectively. An example of the way you can define the constants of model is shown at the following image. 

<img src="images/down.png" width=350>

These results are simultateously plotted in a graph by clicking the box of "Create Graph" in the same window to be examined easy from the reader.    

Then you have to open the prism software again and open file of the attack case scenario "DownUpStreams_Attack.pm" to run the same experiment as described before. The only thing that the reader have to take care of is the intervention rate, which the reader has to set it manually at the ONU and OLT module of the model. Hence, if the reader wants to take results for the intervention rate of 0.5, you have to set this value in the lines 195 and 274 at the ONU and Attaker modules, correspondingly. But if you want to take the results for the intervention rate of 0.99 then you have set the 0.01 and 0.99 values in the same lines to take the worst case scenario.        

Besides, you can derive the quantitative results of the number of sleep requests and ack messages to calculate the percentage of sleep requests acceptance. You have to run the properties of R{“sleep”}=? [C≤C0] and R{“ack”}=? [C≤C0] using the defined values of queries Q2 which considers the realistic scenario of packets’ transmission in both directions; we fix theupstream rate at0.7×10^ 2and vary the downstream one from 0.2×10^2 to 1×10^2 packets/ms.   

Correspondigly, you can measure the energy saving by running the property R{“energy_saving”}=? [C≤C0] using the defined values in query Q4 which measures the ONU's energy consumption.   

# Contribution
We welcome any contributions to the EPON-MITM attack model development through pull requests on GitHub.
