# Clock Definition
create_clock -name CLK_50 -period 9 [get_ports {CLOCK_50}]

# Input Delays
set_input_delay 0.1 -clock CLK_50 [all_inputs]

# Output Delays
set_output_delay 0.1 -clock CLK_50 [all_outputs]


