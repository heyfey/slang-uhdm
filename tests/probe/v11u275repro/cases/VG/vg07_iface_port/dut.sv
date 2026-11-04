// § ifaceGenCaLhsUnbound275 — an interface port signal assigned in its generate scope
package p;
  typedef struct packed { int unsigned n; } cfg_t;
  localparam cfg_t LIT = '{n: 6};
endpackage
interface ifc #(parameter p::cfg_t C = p::LIT) (output logic [31:0] y);
  if (1) begin : gi
    assign y = C.n;
  end
endinterface
module dut (output logic [31:0] o);
  ifc u (.y(o));
endmodule
