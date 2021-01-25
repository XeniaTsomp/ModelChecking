# Quantitative Model Checking for Assessing theEnergy Impact of a MITM Attack on EPONs
This is a model checking approach of an Ethernet Passive Optical Network (EPON) under a MITM attack on an energy-efficient mechanism. It is built in Prism model checker as a CTMC model. 
The modules of the OLT and an ONU along with their queues are modeled to represent the OLT-ONU communication in no attack case senario.
Then, the module of the attacker is added to represent the MITM attack.

# Purpose
Downstream traffic broadcasting makes the Ethernet Passive Optical Networks (EPON) vulnerable to eavesdropping and consequently to Man in the Middle (MITM) attack. 
A MITM attack in energy-efficient mechanisms could turn an EPON into a large energy consumer.
Optical Network Units (ONUs) are the most energy-consuming equipment, responsible for almost 65% of the total EPON power consumption. 

# Methodology

//Message exchange of the energy-efficient mechanism: 
When the OLT has no traffic in its queue it sends a sleep request to the ONU. If the ONU has no upstrean traffic in its queue, it accepts the sleep request, sends an ack message to the OLT and turns to sleep mode.
Otherwise, if the ONU has upstream traffic in its queue, it sends a nack message and remains active until a new sleep message is sent by the OLT.

//MITM attack on the message exchange of the energy-efficient mechanism: 
The attacker intervens to the message exchange of the energy-efficient mechanism, intercepts the OLT's sleep requests and replies to the OLT with a nack message for each requests. Hence, the ONU remains active though its queue is empty.  

//Properties specification: 
A number of properties are implemented to the model to derive the quantitative results in the epon.pctl file.  

# Prism Installation
PRISM is free and open source software. You can download both the tool and its source code for free from the following link.
<img src="images/prim model checker.png">

# Run the model

# Run the Properties of the model

# Take the quantitative results

# Contribution
