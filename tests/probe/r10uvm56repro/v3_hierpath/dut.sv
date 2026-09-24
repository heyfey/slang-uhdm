// r10uvm56 VERIFIER arm v3 — HOW WIDE IS § retNameNewLhsNoBind56?
// The shipped predicate is NOT "the artefact hier_path § invalidNewCallFromSyntax55
// built".  It is, verbatim:
//     const UHDM::BaseClass* p56 = r->VpiParent();
//     drop56 = p56 && p56->UhdmType() == UHDM::uhdmhier_path;
// i.e. ANY return-name reference whose PARENT IS A HIER_PATH loses its binding,
// at EVERY scope, whether pass 55 made that hier_path or the source did.  a8
// only ever built `<name> = new(...)`.  This arm builds the OTHER ways a
// return-name reference acquires a hier_path parent, all at NON-class scope so
// § classMethodRetNameNoBind56 cannot mask the answer:
//   (v3a) struct return, member LVALUE and member READ, module scope
//   (v3b) CLASS-HANDLE return, member lvalue and member read, module scope
//   (v3c) CLASS-HANDLE return, NESTED member (deep hier_path), module scope
//   (v3e) the same two at PACKAGE scope
package p3v;
   typedef struct packed {
      int a;
      int b;
   } s3_t;

   class inner3;
      int v;
   endclass

   class h3;
      int v;
      inner3 inner;
   endclass

   // (v3e) package free function, struct return, member lvalue + read
   function s3_t q_struct(int y);
      q_struct.a = y;
      if (q_struct.a == 0)
        q_struct.b = 1;
   endfunction
   // (v3e) package free function, class-handle return, member lvalue + read
   function h3 q_class(int y);
      q_class = new();
      q_class.v = y;
      if (q_class.v == 0)
        q_class.v = 1;
   endfunction
endpackage

module v3_top;
   import p3v::*;

   // (v3a) struct return at module scope: member lvalue and member read
   function p3v::s3_t z_struct(int y);
      z_struct.a = y;
      if (z_struct.a == 0)
        z_struct.b = 1;
   endfunction

   // (v3b) class-handle return at module scope: member lvalue and member read
   function p3v::h3 z_class(int y);
      z_class = new();
      z_class.v = y;
      if (z_class.v == 0)
        z_class.v = 1;
   endfunction

   // (v3c) NESTED member through the return handle
   function p3v::h3 z_deep(int y);
      z_deep = new();
      z_deep.inner = new();
      z_deep.inner.v = y;
      if (z_deep.inner.v == 0)
        z_deep.inner.v = 1;
   endfunction

   int r;
   p3v::s3_t sv;
   p3v::h3 hv;
   initial begin
      sv = z_struct(1);
      hv = z_class(1);
      hv = z_deep(1);
      sv = p3v::q_struct(1);
      hv = p3v::q_class(1);
      r  = sv.a;
   end
endmodule
