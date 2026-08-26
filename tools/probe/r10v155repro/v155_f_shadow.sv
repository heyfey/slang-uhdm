// p3 — the OTHER shadow channels slang's Scope::find cannot see.
module modNameClash155v; endmodule          // a MODULE named like a local typedef
interface ifcNameClash155v; endinterface    // an INTERFACE ditto

package pbase155v;
  class Base155v;
    typedef int inheritTd155v;              // a BASE-CLASS typedef
    class NestedInBase155v; int q; endclass // a BASE-CLASS nested CLASS
  endclass
  class Derived155v extends Base155v;
    function void g155v();
      typedef byte nestedClash155v;         // name of a nested class in the base? no - unique
      nestedClash155v vNested155v;
      vNested155v = 8'd1;
    endfunction
  endclass
endpackage

module mClash155v;
  initial begin
    typedef byte modNameClash155v;          // shadows a MODULE name
    modNameClash155v vMod155v;
    vMod155v = 8'd2;
  end
  initial begin
    typedef byte ifcNameClash155v;          // shadows an INTERFACE name
    ifcNameClash155v vIfc155v;
    vIfc155v = 8'd3;
  end
endmodule

// A DERIVED class method-local typedef named after a NESTED CLASS of the base.
package pderiv155v;
  class B2155v;
    class InnerB2155v; int z; endclass
  endclass
  class D2155v extends B2155v;
    function void h155v();
      typedef byte InnerB2155v;             // shadows the INHERITED nested class
      InnerB2155v vInner155v;
      vInner155v = 8'd4;
    endfunction
  endclass
endpackage

// A type parameter of an ENCLOSING GENERIC CLASS shadowed by a method-local td.
package pgen155v;
  class G155v #(parameter type TP155v = int);
    function void k155v();
      typedef byte TP155v;                  // shadows the class TYPE PARAMETER
      TP155v vTp155v;
      vTp155v = 8'd5;
    endfunction
  endclass
endpackage
module mGenUse155v;
  pgen155v::G155v#(shortint) gi155v;
  pderiv155v::D2155v d2155v;
  pbase155v::Derived155v dv155v;
  initial begin gi155v = new(); d2155v = new(); dv155v = new(); end
endmodule
