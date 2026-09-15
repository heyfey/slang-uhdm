// v11u42 arm v4 — VIEW faces: procedural, task/function, range/part selects, depth.
package pv4;
  localparam int unsigned LP = 8;
  localparam int unsigned W  = 2;
  typedef struct packed { logic [15:0] m; logic [3:0] t; } s_t;
  typedef struct packed { s_t inner; logic [3:0] z; } n_t;
  typedef struct packed { logic [1:0][7:0] pr; logic [3:0] tg; } a_t;
  function automatic logic fpk(s_t a);
    return a.m[LP-1];                       // c01 inside a PACKAGE function
  endfunction
endpackage

module v4 (input logic [23:0] w24, input logic clk, output logic [63:0] o);
  pv4::s_t v; pv4::n_t nv; pv4::a_t av; pv4::s_t rv;
  assign v  = w24[19:0];
  assign nv = w24;
  assign av = w24[19:0];

  assign o[0] = v.m[pv4::LP-1 -: pv4::W];   // c02 indexed part-select base
  assign o[1] = v.m[pv4::LP-1 : pv4::LP-4]; // c03 range select
  assign o[2] = nv.inner.m[pv4::LP-1];      // c04 depth 2
  assign o[3] = av.pr[pv4::LP-7][pv4::LP-5];// c05 array elem then bit
  assign o[4] = pv4::fpk(v);                // c06 pkg function call

  logic q;
  always_ff @(posedge clk) begin
    q <= v.m[pv4::LP-1];                    // c07 sequential rvalue
  end
  always_comb begin
    rv = '0;
    rv.m[pv4::LP-1] = 1'b1;                 // c08 procedural lvalue
    rv.t[pv4::LP-6] = 1'b1;                 // c09 second lvalue
  end
  task automatic tk(output logic r);
    r = v.m[pv4::LP-2];                     // c10 inside a task
  endtask
  logic tr;
  always_comb tk(tr);
  assign o[5] = q; assign o[6] = rv.m[0]; assign o[7] = tr;
endmodule
