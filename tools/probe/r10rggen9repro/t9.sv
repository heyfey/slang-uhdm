// r10rggen9 t9: the OTHER halves of § ifacePortVarHighConn — an interface port
// written WITHOUT a modport, and an interface whose members are its own PORTS
// (the OneNetInterf shape, which regressed on the first cut).  Each `mid*`
// module reaches an interface signal through its own interface port and feeds
// it to a leaf instance; only the difference named in the comment varies.
interface ifc;
  logic       valid;
  logic [7:0] address;
  modport mp (input valid, input address);
endinterface

// an interface whose members are PORTS of the interface itself
interface pifc (input wire pin, output reg pout);
endinterface

module leaf (input logic i_a, input logic [7:0] i_b, output logic o);
  assign o = i_a & (i_b != 0);
endmodule

module leaf1 (input wire inp, output reg outp);
  assign outp = inp;
endmodule

// A: interface port WITH a modport (the Rggen shape — binds the var)
module midA (ifc.mp mif, output logic o);
  leaf u (.i_a(mif.valid), .i_b(mif.address), .o(o));
endmodule

// B: interface port with NO modport, internal signals
module midB (ifc bif, output logic o);
  leaf u (.i_a(bif.valid), .i_b(bif.address), .o(o));
endmodule

// C: interface port with NO modport, members are the INTERFACE's own PORTS
module midC (pifc pif);
  leaf1 u (.inp(pif.pin), .outp(pif.pout));
endmodule

module top (input wire i, output reg o, output logic oa, output logic ob);
  ifc  u_if ();
  pifc u_pif (.pin(i), .pout(o));

  assign u_if.valid   = i;
  assign u_if.address = 8'h5a;

  midA a (u_if, oa);
  midB b (u_if, ob);
  midC c (u_pif);
endmodule
