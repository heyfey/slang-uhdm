// § tpOvrTypedefStructSpan152
module sub #(parameter type T = logic) (input logic [11:0] a_i, output logic o);
    wire T [1:0] q;
    assign q = a_i;
    assign o = ^q;
endmodule
module tb(output logic o);
    typedef struct packed { logic [3:0] x; logic [1:0] y; } my_t;
    sub #(.T(my_t)) d (.a_i('0), .o(o));
endmodule
