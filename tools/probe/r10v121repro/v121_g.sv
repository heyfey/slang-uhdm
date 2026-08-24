// r10uvm121 VERIFIER arm G — a class at $unit (compilation-unit) scope, an
// AUTOMATIC method, a STATIC method beside it, and a constructor with default
// arguments.  No package and no enclosing module for the class itself.
class Kerf;
   int width;
   function new(int w = 1); width = w; endfunction
endclass

class Saw;
   Kerf blade;
   Kerf tooth;
   Kerf set;
   Kerf rake;
   static Kerf jig;
   int teeth;

   function new(int t = 3);
      teeth      = t;
      this.blade = new(t);          // G01 $unit-scope class ctor
   endfunction

   function automatic void file_it(int k);
      if (k == 1)
         this.tooth = new;          // G02 AUTOMATIC method, kept slot
   endfunction

   static function int count();
      return 7;                     // static: no `this` is legal here
   endfunction

   function void kerf_it(int k);
      case (k)
         1: this.set  = new(2);     // G03 case_item
         2: this.rake = new;        // G04 case_item
      endcase
   endfunction
endclass

module kerf_top;
  Saw s;
  initial begin
    s = new(4);
    s.file_it(1);
  end
endmodule
