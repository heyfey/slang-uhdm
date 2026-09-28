// § unitClassTdEndAtInitIfcPrg206
class plain; endclass
typedef plain p_t;
interface ifc ();
  p_t a = new;
endinterface
module top ();
  ifc i ();
endmodule
