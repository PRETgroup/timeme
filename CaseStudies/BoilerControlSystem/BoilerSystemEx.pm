mdp

const int intOpenInput = 0;
const bool boolOpenInput = false;

//parameter list
const int PARAM_threshold_controller = 300;

//state labels
label "CLOSED_controller" = (s_controller=0);
label "OPEN_controller" = (s_controller=1);
label "Violation" = (s_observer=1);


module controller
	s_controller : [-1..1] init -1;
	//s_controller=0 - CLOSED
	//s_controller=1 - OPEN

	//Generated from output events
	trigger_controller : bool init false;

	//Generated from internal and output variables
	valveCtl_controller : bool init false;

	[Tick] (s_controller=-1) -> (s_controller'=0) & (trigger_controller'=true) & (valveCtl_controller' = false);
	[Tick] (s_controller=0) & (((changed_source | output_flow_1oo2) & (pressure_source > PARAM_threshold_controller))) -> (s_controller'=1) & (trigger_controller'=true) & (valveCtl_controller' = true);
	[Tick] (s_controller=1) & (((changed_source | output_flow_1oo2) & (pressure_source <= PARAM_threshold_controller))) -> (s_controller'=0) & (trigger_controller'=true) & (valveCtl_controller' = false);

	//Generated self-loops for emulating synchronous execution semantics
	[Tick] (s_controller=0) & (((((changed_source | output_flow_1oo2)) = false) | (pressure_source <= PARAM_threshold_controller))) -> (s_controller'=0) & (trigger_controller'=false);
	[Tick] (s_controller=1) & (((((changed_source | output_flow_1oo2)) = false) | (pressure_source > PARAM_threshold_controller))) -> (s_controller'=1) & (trigger_controller'=false);
endmodule


module source
	s_source : [-1..3] init -1;
	//s_source=0 - HIGH
	//s_source=1 - LOW
	//s_source=2 - INC
	//s_source=3 - DEC

	//Generated from output events
	changed_source : bool init false;

	//Generated from internal and output variables
	pressure_source : [0..1000] init 0;
	flow_1_source : bool init false;
	flow_2_source : bool init false;
	counter_source : [0..10] init 0;

	[Tick] (s_source=-1) -> (s_source'=1) & (changed_source'=true) & (counter_source' = (counter_source < 10) ? (counter_source + 1) : counter_source) & (flow_1_source' = (pressure_source > 300) ? true : false) & (flow_2_source' = (pressure_source > 300) ? true : false);
	[Tick] (s_source=1) & ((counter_source >= 10)) -> (s_source'=2) & (changed_source'=true) & (pressure_source' = 350) & (counter_source' = 0);
	[Tick] (s_source=2) -> (s_source'=0) & (changed_source'=true) & (counter_source' = (counter_source < 10) ? (counter_source + 1) : counter_source) & (flow_1_source' = (pressure_source > 300) ? true : false) & (flow_2_source' = (pressure_source > 300) ? true : false);
	[Tick] (s_source=0) & ((counter_source >= 10)) -> (s_source'=3) & (changed_source'=true) & (pressure_source' = 250) & (counter_source' = 0);
	[Tick] (s_source=3) -> (s_source'=1) & (changed_source'=true) & (counter_source' = (counter_source < 10) ? (counter_source + 1) : counter_source) & (flow_1_source' = (pressure_source > 300) ? true : false) & (flow_2_source' = (pressure_source > 300) ? true : false);
	[Tick] (s_source=1) & ((counter_source < 10)) -> (s_source'=1) & (changed_source'=true) & (counter_source' = (counter_source < 10) ? (counter_source + 1) : counter_source) & (flow_1_source' = (pressure_source > 300) ? true : false) & (flow_2_source' = (pressure_source > 300) ? true : false);
	[Tick] (s_source=0) & ((counter_source < 10)) -> (s_source'=0) & (changed_source'=true) & (counter_source' = (counter_source < 10) ? (counter_source + 1) : counter_source) & (flow_1_source' = (pressure_source > 300) ? true : false) & (flow_2_source' = (pressure_source > 300) ? true : false);
endmodule


module flow_1oo2
	s_flow_1oo2 : [-1..2] init -1;
	//s_flow_1oo2=0 - IDLE
	//s_flow_1oo2=1 - INPUT1
	//s_flow_1oo2=2 - INPUT2

	//Generated from output events
	output_flow_1oo2 : bool init false;

	//Generated from internal and output variables
	oValue_flow_1oo2 : bool init false;

	[Tick] (s_flow_1oo2=-1) -> (s_flow_1oo2'=0) & (output_flow_1oo2'=false);
	[Tick] (s_flow_1oo2=0) & ((output_compFI_1 = true)) -> (s_flow_1oo2'=1) & (output_flow_1oo2'=true) & (oValue_flow_1oo2' = oValue_compFI_1);
	[Tick] (s_flow_1oo2=0) & ((output_compFI_1 = false) & (output_compFI_2 = true)) -> (s_flow_1oo2'=2) & (output_flow_1oo2'=true) & (oValue_flow_1oo2' = oValue_compFI_2);
	[Tick] (s_flow_1oo2=1) & ((output_compFI_2 = true)) -> (s_flow_1oo2'=2) & (output_flow_1oo2'=true) & (oValue_flow_1oo2' = oValue_compFI_2);
	[Tick] (s_flow_1oo2=2) & ((output_compFI_1 = true)) -> (s_flow_1oo2'=1) & (output_flow_1oo2'=true) & (oValue_flow_1oo2' = oValue_compFI_1);
	[Tick] (s_flow_1oo2=2) & ((output_compFI_1 = false) & (output_compFI_2 = true)) -> (s_flow_1oo2'=2) & (output_flow_1oo2'=true) & (oValue_flow_1oo2' = oValue_compFI_2);
	[Tick] (s_flow_1oo2=1) & ((output_compFI_2 = false) & (output_compFI_1 = true)) -> (s_flow_1oo2'=1) & (output_flow_1oo2'=true) & (oValue_flow_1oo2' = oValue_compFI_1);

	//Generated self-loops for emulating synchronous execution semantics
	[Tick] (s_flow_1oo2=0) & ((output_compFI_1 = false) & (output_compFI_2 = false)) -> (s_flow_1oo2'=0) & (output_flow_1oo2'=false);
	[Tick] (s_flow_1oo2=1) & ((output_compFI_2 = false) & (output_compFI_1 = false)) -> (s_flow_1oo2'=1) & (output_flow_1oo2'=false);
	[Tick] (s_flow_1oo2=2) & ((output_compFI_1 = false) & (output_compFI_2 = false)) -> (s_flow_1oo2'=2) & (output_flow_1oo2'=false);
endmodule


module compFI_1
	s_compFI_1 : [-1..1] init -1;
	//s_compFI_1=0 - START
	//s_compFI_1=1 - INPUT_REC

	//Generated from output events
	output_compFI_1 : bool init false;

	//Generated from internal and output variables
	oValue_compFI_1 : bool init false;

	[Tick] (s_compFI_1=-1) -> (s_compFI_1'=0) & (output_compFI_1'=false);
	[Tick] (s_compFI_1=0) & (s_fail_1 = 0) & (changed_source = true) -> (s_compFI_1'=1) & (output_compFI_1'=true) & (oValue_compFI_1' = flow_1_source);
	[Tick] (s_compFI_1=1) & (s_fail_1 = 0) & (changed_source = true) -> (s_compFI_1'=1) & (output_compFI_1'=true) & (oValue_compFI_1' = flow_1_source);

	//Generated self-loops for emulating synchronous execution semantics
	[Tick] (s_compFI_1=0) & ((s_fail_1 = 1) | (changed_source = false)) -> (s_compFI_1'=0) & (output_compFI_1'=false);
	[Tick] (s_compFI_1=1) & ((s_fail_1 = 1) | (changed_source = false)) -> (s_compFI_1'=1) & (output_compFI_1'=false);
endmodule


module compFI_2
	s_compFI_2 : [-1..1] init -1;
	//s_compFI_2=0 - START
	//s_compFI_2=1 - INPUT_REC

	//Generated from output events
	output_compFI_2 : bool init false;

	//Generated from internal and output variables
	oValue_compFI_2 : bool init false;

	[Tick] (s_compFI_2=-1) -> (s_compFI_2'=0) & (output_compFI_2'=false);
	[Tick] (s_compFI_2=0) & (s_fail_2 = 0) & (changed_source = true) -> (s_compFI_2'=1) & (output_compFI_2'=true) & (oValue_compFI_2' = flow_2_source);
	[Tick] (s_compFI_2=1) & (s_fail_2 = 0) & (changed_source = true) -> (s_compFI_2'=1) & (output_compFI_2'=true) & (oValue_compFI_2' = flow_2_source);

	//Generated self-loops for emulating synchronous execution semantics
	[Tick] (s_compFI_2=0) & ((s_fail_2 = 1) | (changed_source = false)) -> (s_compFI_2'=0) & (output_compFI_2'=false);
	[Tick] (s_compFI_2=1) & ((s_fail_2 = 1) | (changed_source = false)) -> (s_compFI_2'=1) & (output_compFI_2'=false);
endmodule


module observer
	s_observer : [-1..3] init -1;
	//s_observer=0 - Start
	//s_observer=1 - Violation
	//s_observer=2 - STEP1
	//s_observer=3 - STEP2

	[Tick] (s_observer=-1) -> (s_observer'=0);
	[Tick] (s_observer=0) & ((trigger_controller = true)) -> (s_observer'=2);
	[Tick] (s_observer=2) & ((trigger_controller = false)) -> (s_observer'=3);
	[Tick] (s_observer=3) & ((output_flow_1oo2 & (oValue_flow_1oo2 = valveCtl_controller))) -> (s_observer'=0);
	[Tick] (s_observer=2) & ((trigger_controller = true)) -> (s_observer'=2);
	[Tick] (s_observer=3) & (((output_flow_1oo2 = false) | (oValue_flow_1oo2 != valveCtl_controller))) -> (s_observer'=1);

	//Generated self-loops for emulating synchronous execution semantics
	[Tick] (s_observer=0) & ((trigger_controller = false)) -> (s_observer'=0);
	[Tick] (s_observer=1) -> (s_observer'=1);
endmodule

module fail_1
	s_fail_1 : [0..1] init 0;
	[Tick] (s_fail_1=0) -> 1-2.8E-10 : (s_fail_1'=0) + 2.8E-10 : (s_fail_1'=1);
	[Tick] (s_fail_1=1) -> (s_fail_1'=1);
endmodule

module fail_2
	s_fail_2 : [0..1] init 0;
	[Tick] (s_fail_2=0) -> 1-2.8E-10 : (s_fail_2'=0) + 2.8E-10 : (s_fail_2'=1);
	[Tick] (s_fail_2=1) -> (s_fail_2'=1);
endmodule