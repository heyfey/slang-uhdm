// § pkgTdSameNameOrphan124
package pa; typedef struct packed {logic [1:0] x;} st_t; endpackage
package pb; typedef struct packed {logic [2:0] y;} st_t; endpackage
module top(input pa::st_t ia, input pb::st_t ib, output pa::st_t oa, output pb::st_t ob); assign oa = ia; assign ob = ib; endmodule
