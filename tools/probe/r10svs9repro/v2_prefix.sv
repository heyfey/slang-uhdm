// r10svs9 VERIFIER arm v2 — EMPTY PRODUCT CELLS: the FULLNAME.
//
// § parensLessEventPathBaseRef9 mints vpiFullName as joinRef(prefix, base),
// where `prefix` is whatever the enclosing emitter passed.  Every cell in the
// implementer's grid has the base declared DIRECTLY in the scope whose prefix is
// in flight (a class method's own property, a module's own instance), so
// joinRef is trivially right there.  These cells break that assumption:
//
//   m1  base is a PACKAGE variable reached through a wildcard import — golden
//       should name it work@pk::pst, ours would join it onto work@top
//   m2  base is an INTERFACE PORT of the module (not an instance)
//   m3  base is declared inside a NAMED GENERATE BLOCK, referenced from an
//       always inside that block
//   m4  base is a STATIC class property referenced from a static method
//   m5  base is declared in the INTERFACE itself and read from an always there
package pk;
    typedef struct packed { logic f; logic g; } st_t;
    st_t pst;
endpackage

interface in_if(input bit clock);
    logic rdy;
    // m5 — inside the interface, dotted parens-less over the interface's own
    // struct variable
    pk::st_t ist;
    always @ ist.f begin
    end
    modport IP(input clock, input rdy);
endinterface

module sub(in_if.IP p);
    // m2 — the base is an INTERFACE PORT of this module
    always @ p.clock begin
    end
    always @(p.clock) begin
    end
endmodule

module top;
    import pk::*;
    bit clock;
    in_if u_if(clock);
    sub u_sub(u_if);

    // m1 — base is the PACKAGE's own variable, reached by wildcard import
    always @ pst.f begin
    end
    always @(pst.f) begin
    end

    // m3 — base declared inside a NAMED GENERATE BLOCK
    if (1) begin : g
        pk::st_t gst;
        always @ gst.f begin
        end
        always @(gst.f) begin
        end
    end

    // m4 — STATIC class property, read from a STATIC method
    class C;
        static pk::st_t sst;
        static task t();
            @ sst.f;
        endtask
        static task t2();
            @(sst.f);
        endtask
    endclass
endmodule
