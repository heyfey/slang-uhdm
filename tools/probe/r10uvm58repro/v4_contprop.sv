// r10uvm58 VERIFIER v4 — § typeParamRetIsRefVar58's ONE EXCLUSION, as a repro.
// A CLASS PROPERTY whose type is a CONTAINER of the type parameter is the shape
// mv58.sh caught this pass over-firing on: uvm_queue's `protected T queue[$];`
// (uvm_queue.svh:43) is an int_var in golden — a class property is compiled by
// ElaborationStep's Parameter branch, which RESOLVES the parameter — while the
// `T`-returning method right beside it is a ref_var.  A SUBROUTINE-LOCAL
// container of T is the positive control on the same page.
package p58v4;
   class c_cont #(type T=int) extends uvm_dummy58;
      protected T qprop [$];      // queue PROPERTY      -> golden int_var
      protected T aprop [3];      // fixed-array PROPERTY
      protected T asprop [string];// associative PROPERTY
      T splain;                   // scalar PROPERTY     -> golden int_var
      function bit m();
         T qloc [$];              // queue LOCAL         -> golden ref_var
         T sloc;                  // scalar LOCAL        -> golden ref_var
         qloc = qprop;
         sloc = splain;
         return 1;
      endfunction
      function T get(int i);      // type-param RETURN   -> golden ref_var
         return qprop[i];
      endfunction
   endclass
endpackage

class uvm_dummy58; int d; endclass

module v4_top58;
   initial begin end
endmodule
