// § pkgTdSameNameOrphan124
package pa; typedef enum logic [1:0] {IDLE, RUN, DONE} st_t; endpackage
module top(input pa::st_t i, output pa::st_t o); assign o = i; endmodule
