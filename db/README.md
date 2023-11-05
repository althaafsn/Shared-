[![Review Assignment Due Date](https://classroom.github.com/assets/deadline-readme-button-24ddc0f5d75046c5622901739e7c5dd533143b0c8e959d652212380cedb1ea36.svg)](https://classroom.github.com/a/M0QWww3N)
[![Open in Visual Studio Code](https://classroom.github.com/assets/open-in-vscode-718a45dd9cf7e7f842a935f5ebbe5719a5e09af4491e668f4dbf3b35d5cca122.svg)](https://classroom.github.com/online_ide?assignment_repo_id=12671254&assignment_repo_type=AssignmentRepo)
# starter-lab-5

Starter code for CPEN 211 Lab 5

See the Lab 5 handout on Piazza for details of what you need to do and what files
need to be included.  

DE1_SoC.qsf includes pins assignments (import in Quartus before synthesis using the 
same procedure used for pb-pins.csv outline in the HDL tutorial). Do not modify this
file.

Use lab5_top.sv to demo/test your design on your DE1-SoC (read the comments at the
top of the file for how to use it).  

Use lab5_autograder_check.sv to test your code is compatible with the autograder
that will be used to assign marks for your submission.  
WARNING: The purpose of the checker file is NOT to tell you if your code is ``correct''.
If your code does not passing the checks in this file means your code
will certainly get zero marks for the autograded portion.
Passing the checks in 
this file DOES NOT mean your code will get full marks.  Your code can pass these
checks and get zero marks.  You still need to test your code using your own
test benches!

Below is a (potentially incomplete) summary of files you need to add (check the 
lab 5 handout instructions for details on what goes in these and any other
necessary files):

1. Your synthesizable and testbench code in files named:
- regfile.sv
- regfile_tb.sv
- alu.sv
- alu_tb.sv
- shifter.sv
- shifter_tb.sv
- datapath.sv
- datapath_tb.sv

2. A Quartus Project File (.qpf) and the associated
Quartus Settings File (.qsf) that indicates which Verilog files are part of
your project when compiling for your DE1-SoC. This .qsf file is created by Quartus when you create a project.
It is typically named <top_leve_module_name>.qsf (e.g., lab5_top.qsf) and 
contains lines indicating which Verilog files are to be synthesized.

2. A Modelsim Project File (.mpf) for your testbench simulations including
all synthesizable code files.

3. The binary output file (.sof), generated from your synthesizable SystemVerilog
 used to program your DE1-SoC.  Your TAs may ask you to use the .sof generated when the 
autograder synthesizes your design, if we have it available in time. However, include
the one you generated as a backup to speed up the marking process during your demo.  
