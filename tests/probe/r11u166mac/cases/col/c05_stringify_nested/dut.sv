// § ppOutputCol166
`define STR(__x) `"__x`"
`define CHK(__name) \
  initial $display("%s", \
                   `STR(__name));
module top;
  `CHK(Name1)
endmodule
