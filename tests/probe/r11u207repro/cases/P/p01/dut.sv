// § parenCastWidthRefPkgBare207: package localparams used as parenthesized cast widths of hex literals with and without wildcards (BlackBePipeInt's shape), no importer
package p;
  localparam dev_w = 4;
  localparam addr_w = 20;
  localparam wide_a = (dev_w+addr_w)'('h0010_0000);
  localparam wide_m = (dev_w+addr_w)'('h001?_????);
  localparam base_a = (addr_w)'('h0_1000);
  localparam match_a = (addr_w)'('h0_1???);
endpackage
module top; endmodule
