// § tpUseSigBindsTpObj291
interface ifc #(parameter type T = logic [3:0]) (input T din);
  T q;
  assign q = din;
  modport mp (input q);
endinterface
module dut (input logic [3:0] a, output logic [3:0] o);
  ifc #(.T(logic [3:0])) u (.din(a));
  assign o = u.q;
endmodule
