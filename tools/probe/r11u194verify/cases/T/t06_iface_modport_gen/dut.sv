// § tpEnumCopyAtTypedef184 § tpEnumCaBindsInstVar184v: an interface with a type parameter overridden by a module enum, a modport, and a continuous assignment of a whole T signal inside a generate block of the interface
interface tif #(parameter type T = logic) ();
  T a, b;
  if (1) begin : g
    assign b = a;
  end
  modport mp (input a, output b);
endinterface
module top (output logic [2:0] c);
  typedef enum logic [2:0] {Q0, Q1 = 3'd4} q_e;
  tif #(.T(q_e)) i ();
  assign c = i.b;
endmodule
