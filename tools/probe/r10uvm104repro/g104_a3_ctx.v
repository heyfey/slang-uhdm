// r10uvm104 arm 3 — the CONTEXT matrix (a .v file on purpose).  The same
// stringification used as a package parameter, a module parameter, a
// localparam, an assignment Rhs, a system-task argument and a case item.
`define ZN QRS
`define ZM 9
`define ZS `"`ZN``:```ZM`"
package ctx_pk;
  parameter  string c_par = `ZS;
  localparam string c_loc = `ZS;
endpackage
module ctx_top;
  parameter  string m_par = `ZS;
  localparam string m_loc = `ZS;
  string w;
  initial begin
    w = `ZS;
    $display(`ZS);
    case (w)
      `ZS: w = "hit";
      default: w = "miss";
    endcase
  end
endmodule
