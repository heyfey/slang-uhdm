// § impSizeCastFoldLocated252
package p;
   parameter logic [2:0] PartInvDefault = 3'({
                                              3'({
                                                  3'h1
                                                  })
                                              });
endpackage : p
module top(output int o);
   import p::*;
   logic [$bits(PartInvDefault)/1-1:0] part_buf_data = '1;
   assign o = int'(part_buf_data);
endmodule
