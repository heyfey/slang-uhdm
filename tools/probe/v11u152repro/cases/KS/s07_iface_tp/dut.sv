// § tpOvrTypedefStructSpan152
interface ifc #(parameter type T = logic);
    T [1:0] q;
endinterface
module tb(output logic o);
    typedef struct packed { logic [3:0] x; logic [1:0] y; } my_t;
    ifc #(.T(my_t)) i();
    assign o = ^i.q;
endmodule
