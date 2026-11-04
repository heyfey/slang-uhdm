// § pkgTdSameNameOrphan124
package pa; typedef logic [1:0] st_t; endpackage
package pb; typedef logic [2:0] st_t; endpackage
module top(input pa::st_t ia, input pb::st_t ib, output pa::st_t oa, output pb::st_t ob); assign oa = ia; assign ob = ib; endmodule
