// qg26 — the ONE residue pass 26's EXISTENCE-CENSUS delta still shows on the
// ADDED side after all four laws: `work@tlul_assert_multiple.d2h` and `.h2d`,
// where OURS carries ONE MORE ref_typespec with that fullname than golden
// (G=x5 O=x6, exid26.sh base fin).  Those are DEF-VIEW names (no instance
// path).  Shape, from tlul_assert_multiple.sv:
//     module M #(parameter int unsigned N = 2, parameter EndpointType = "Device")
//              (input pkg::struct_t h2d [N], input pkg::struct_t d2h [N]);
//       for (genvar ii = 0; ii < N; ii++) begin : gen_assert
//         child #(.EndpointType(EndpointType)) c (.h2d (h2d[ii]), .d2h (d2h[ii]));
//       end
// Everything below is that, with the features separated one per port so the
// next pass can bisect: a STRUCT element type from a package, an unpacked dim
// sized by the module's OWN un-overridden `int unsigned` parameter, a SECOND
// string-typed parameter passed down, and a for-generate that element-selects
// the port.  The instantiations give N a literal override AND a localparam
// override so both chain roots are present.
// DIRECTION TO CHECK: LHS(golden) is the `<` side of rd26.sh's diff; the
// question is which ref_typespec OURS has that golden does not.
package qg26_pkg;
  typedef struct packed { logic v; logic [1:0] q; } h2d_t;
  typedef struct packed { logic r; logic [1:0] s; } d2h_t;
endpackage

module qg26_leaf #(
    parameter EndpointType = "Device"
) (
    input qg26_pkg::h2d_t h2d,
    input qg26_pkg::d2h_t d2h,
    output logic y
);
  assign y = h2d.v ^ d2h.r ^ (EndpointType == "Device");
endmodule

module qg26_multi #(
    parameter int unsigned N = 2,
    parameter EndpointType = "Device"
) (
    input  qg26_pkg::h2d_t h2d [N],
    input  qg26_pkg::d2h_t d2h [N],
    output logic [N-1:0]   y
);
  for (genvar ii = 0; ii < N; ii++) begin : gen_assert
    qg26_leaf #(.EndpointType (EndpointType)) u_leaf (
        .h2d (h2d[ii]), .d2h (d2h[ii]), .y (y[ii]));
  end
endmodule

module qg26 (
    output logic [2:0] y3,
    output logic [4:0] y5
);
  localparam int unsigned NL = 5;
  qg26_pkg::h2d_t h3 [3];
  qg26_pkg::d2h_t d3 [3];
  qg26_pkg::h2d_t h5 [NL];
  qg26_pkg::d2h_t d5 [NL];
  // literal chain root
  qg26_multi #(.N (3))  u_lit (.h2d (h3), .d2h (d3), .y (y3));
  // localparam chain root (the narrow one § dimFoldOverrideChainWidth26 is about)
  qg26_multi #(.N (NL)) u_par (.h2d (h5), .d2h (d5), .y (y5));
endmodule
