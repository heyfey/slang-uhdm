// § pkgTdSameNameOrphan124
package pa; typedef enum logic [1:0] {IDLE, RUN, DONE} st_t; endpackage
package pb; typedef enum logic [2:0] {XIDLE = 3'd4} st_t; endpackage
module top(input pa::st_t ia, output pa::st_t oa); assign oa = ia; endmodule
