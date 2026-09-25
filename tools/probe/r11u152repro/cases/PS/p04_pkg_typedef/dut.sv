// § tpOvrTypedefStructSpan152
package pk;
    typedef struct packed { logic [3:0] x; logic [1:0] y; } my_t;
endpackage
module sub #(parameter type T = logic) (input T [1:0] a_i, output logic o);
    assign o = ^a_i;
endmodule
module tb(output logic o);
    pk::my_t [1:0] a;
    assign a = '0;
    sub #(.T(pk::my_t)) d (.a_i(a), .o(o));
endmodule
