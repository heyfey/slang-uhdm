// v11u90 vy16 -- a DRIVE STRENGTH beside the parameter delay: pass 87's law
// says the producer's strength arm swallows the delay, so golden writes NO
// delay here.  LAW B must not put a reference where golden writes nothing.
interface ifc ();
  parameter int D = 4;
  logic [31:0] c;
  assign (strong1, weak0) #D c = 32'd10;
endinterface
module sub (output logic [31:0] o);
  parameter int D = 6;
  logic [31:0] c;
  assign (strong1, weak0) #D c = 32'd11;
  assign o = c;
endmodule
module dut (output logic [31:0] o);
  logic [31:0] q;
  ifc u_if ();
  sub u_s (.o(q));
  assign o = q ^ u_if.c;
endmodule
