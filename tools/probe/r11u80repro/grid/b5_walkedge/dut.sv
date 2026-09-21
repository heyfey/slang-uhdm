// r11u74 b5 — THE EDGES OF LAW B's WALK: does it cross an INSTANCE boundary,
// does it run inside an INTERFACE's generate scope, and does a PARAMETER or a
// TYPEDEF namesake count?
interface ifc;
  logic [31:0] i_ns;
  for (genvar i = 0; i < 1; i = i + 1) begin : gi
    logic [31:0] i_ns;      // namesake in the INTERFACE body
    logic [31:0] i_up;      // namesake only in the INSTANTIATING module
    assign i_ns = 32'd7;
    assign i_up = 32'd7;
  end
endinterface

module leaf (output logic [31:0] lo);
  for (genvar i = 0; i < 1; i = i + 1) begin : gl
    logic [31:0] up_ns;     // namesake only in the PARENT instance's body
    logic [31:0] lf_ns;     // namesake in THIS module's body
    assign up_ns = 32'd7;
    assign lf_ns = 32'd7;
  end
  logic [31:0] lf_ns;
  assign lo = gl[0].up_ns ^ gl[0].lf_ns ^ lf_ns;
  assign lf_ns = 32'd1;
endmodule

module dut (output logic [31:0] o);
  logic [31:0] up_ns;       // the parent-instance namesake candidate
  logic [31:0] i_up;        // the interface's outer namesake candidate
  logic [31:0] lo;
  leaf u (.lo(lo));
  ifc u_if ();
  assign up_ns = 32'd1;
  assign i_up  = 32'd1;
  assign o = lo ^ up_ns ^ i_up ^ u_if.gi[0].i_ns ^ u_if.gi[0].i_up;
endmodule
