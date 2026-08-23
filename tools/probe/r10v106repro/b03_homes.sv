// b03: homes -- $unit, package, module header, module body, interface,
// program, function-local, task-local, generate-if, generate-for,
// generate-case, named begin, class, nested class.
parameter U_UNIT  = 'h11;
localparam U_LUNIT = 'h12;
package b03_pkg;
  parameter K_PKG = 'h22;
endpackage
interface b03_if #(parameter IF_HDR = 'h31) ();
  parameter IF_BODY = 'h32;
  localparam IF_LOC = 'h33;
endinterface
program b03_pgm #(parameter PG_HDR = 'h41) ();
  parameter PG_BODY = 'h42;
  initial $display(PG_HDR, PG_BODY);
endprogram
module b03_hdr #(parameter M_HDR = 'h51, parameter M_HDR2 = 'd52) ();
  initial $display(M_HDR, M_HDR2);
endmodule
module b03_body;
  parameter M_BODY = 'h61;
  localparam M_LOC = 'h62;
  if (1) begin : gi
    localparam G_IF = 'h63;
    initial $display(G_IF);
  end
  for (genvar i = 0; i < 3; i++) begin : gf
    localparam G_FOR = 'h64;
    initial $display(G_FOR);
  end
  case (1)
    1: begin : gc
      localparam G_CASE = 'h65;
      initial $display(G_CASE);
    end
  endcase
  function automatic int fn();
    localparam F_LOC = 'h66;
    return F_LOC;
  endfunction
  task automatic tk();
    localparam T_LOC = 'h67;
    $display(T_LOC);
  endtask
  initial begin : nb
    localparam N_LOC = 'h68;
    $display(N_LOC, fn());
    tk();
  end
  initial $display(M_BODY, M_LOC, U_UNIT, U_LUNIT);
endmodule
class b03_cls #(parameter C_HDR = 'h71);
  parameter C_BODY = 'h72;
  localparam C_LOC = 'h73;
  function int f(); return C_HDR + C_BODY + C_LOC; endfunction
endclass
module b03_top;
  b03_body  b0();
  b03_hdr   h0();
  b03_if    i0();
  b03_pgm   p0();
  b03_cls   c0;
  import b03_pkg::*;
  initial $display(K_PKG);
endmodule
