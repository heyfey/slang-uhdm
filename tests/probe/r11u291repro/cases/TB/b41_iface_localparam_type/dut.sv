// § tpUseSigBindsTpObj291
interface ifc ();
  localparam type LT = shortint;
  LT d;
endinterface
module dut (output logic o);
  ifc u ();
  assign o = ^u.d;
endmodule
