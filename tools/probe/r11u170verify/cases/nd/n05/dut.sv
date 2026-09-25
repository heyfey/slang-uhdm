// § elabTpDefaultDefNamed163
interface bus_if #(parameter int W = 8, parameter type data_t = logic [W-1:0]) ();
  data_t d;
endinterface
module top; bus_if u(); endmodule
