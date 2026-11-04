// § tpOvrTypedefStructSpan152
module leaf #(parameter type T = logic) (output T o);
    assign o = '0;
endmodule
module mid #(parameter type T = logic) (output T o);
    leaf #(.T(T)) l (.o(o));
endmodule
module tb(output logic [5:0] o);
    typedef struct packed { logic [3:0] x; logic [1:0] y; } my_t;
    mid #(.T(my_t)) d (.o(o));
endmodule
