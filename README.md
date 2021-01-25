# Quantitative Model Checking for Assessing theEnergy Impact of a MITM Attack on EPONs
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

### Prism model checker Installation
PRISM is a free and open source software. You can download the tool for free from the following link https://www.prismmodelchecker.org/download.php. 

<img src="images/prim model checker.png">

### Run the CTMC model 

### Run the Properties of the model

### Take the quantitative results

# Contribution
