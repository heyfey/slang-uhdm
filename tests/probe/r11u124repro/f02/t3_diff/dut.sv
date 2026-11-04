// § pkgTdSameNameOrphan124
package pa; typedef enum logic [1:0] {IDLE, RUN, DONE} sa_t; endpackage
package pb; typedef enum logic [2:0] {IDLE = 3'd4, RUN = 3'd5, DONE = 3'd6} sb_t; endpackage
module top(input pa::sa_t ia, input pb::sb_t ib, output pa::sa_t oa, output pb::sb_t ob); assign oa = ia; assign ob = ib; endmodule
