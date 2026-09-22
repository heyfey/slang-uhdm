// r11u86 arm m7 — THE INTERFACE HOME.  § patternHomeIsAPackage81v answers NO
// for an interface, so § modPatHopValueStoreEnc86 FIRES there; this arm
// measures whether golden's interface-homed pattern takes the same Value-store
// route a module-homed one does.  An INSTANTIATED interface, so the pattern is
// elaborated (m4_ctx86's uninstantiated one produced no param_assign at all).
package m7p;
  localparam PD = 16'd5;
  localparam PO = 16'o17;
  localparam PU = 5;
  typedef struct packed {
    logic [23:0] bail; logic [23:0] a; logic [23:0] b; logic [23:0] c;
  } t7;
endpackage
interface m7_if ();
  localparam MD = 16'd5;
  localparam m7p::t7 IFP = '{bail: 8'hxA, a: m7p::PU, b: m7p::PD, c: m7p::PO};
  localparam m7p::t7 IFM = '{bail: 8'hxA, a: m7p::PU, b: MD,      c: m7p::PO};
endinterface
module m7_if86 (output logic [23:0] o);
  m7_if u();
  assign o = u.IFP.a ^ u.IFM.b;
endmodule
