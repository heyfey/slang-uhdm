// § pkgTdSameNameOrphan124
package pa; typedef enum logic [1:0] {IDLE, RUN, DONE} st_t; endpackage
package pb; typedef enum logic [2:0] {IDLE = 3'd4, RUN = 3'd5, DONE = 3'd6} st_t; endpackage
module top(input pa::st_t ia, input pb::st_t ib, output pa::st_t oa, output pb::st_t ob); assign oa = ia; assign ob = ib; endmodule
