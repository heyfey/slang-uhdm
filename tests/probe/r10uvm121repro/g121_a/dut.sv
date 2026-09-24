// r10uvm121 arm a — the KEPT slots for a `this`/`super`-rooted `= new`
// assignment.  § thisSuperNewAssignNoStmt3 already decided WHICH slots keep the
// statement; this arm asks what the KEPT object looks like.
package quill;

class Nib;
   int shade;
   function new(int tone = 0); shade = tone; endfunction
endclass

class Vellum;
   Nib margin;
   Nib gutter;
   Nib folio;
   Nib recto;
   Nib verso;
   Nib colophon;
   Nib incipit;
   Nib explicit_h;
   Nib rubric;
   Nib quire;
   int leaf;
   int sheet[3];
   extern function new(int width);
   extern function void ruling(int k);
endclass

class Palimpsest extends Vellum;
   Nib scrape;
   extern function new(int width);
endclass

// ---- the corpus slot: a constructor's OWN statement list, port list present
function Vellum::new(int width);
   leaf            = width;          // a01 control: plain int assignment
   this.margin     = new;            // a02 CTOR list, this. + bare new
   this.gutter     = new(3);         // a03 CTOR list, this. + new(arg)
   this.folio      = new();          // a04 CTOR list, this. + new()
   this.recto      = new this.margin;// a05 CTOR list, this. + copy new
   verso           = new;            // a06 CTOR list, plain lhs + bare new
   this.leaf       = width + 1;      // a07 CTOR list, this. + non-new rhs
endfunction

function void Vellum::ruling(int k);
   if (k == 1)
      this.colophon = new;           // a08 sole branch of an if
   while (k == 2)
      this.incipit = new(4);         // a09 sole body of a while
   foreach (sheet[i])
      this.explicit_h = new;         // a10 sole body of a foreach
   case (k)
      3: this.rubric = new;          // a11 a case_item's statement
      default: leaf = 0;
   endcase
   if (k == 5)
      quire = new;                   // a12 control: plain lhs, same slot
   if (k == 6)
      this.leaf = k;                 // a13 control: this. + non-new rhs
   begin
      this.margin = new;             // a14 begin list -> DROPPED by golden
      leaf = 9;
   end
endfunction

function Palimpsest::new(int width);
   super.new(width);
   super.gutter = new;               // a15 CTOR list, super. + bare new
   this.scrape  = new(2);            // a16 CTOR list, this. in derived ctor
endfunction

endpackage

module quill_top;
  import quill::*;
  Vellum v;
  initial v = new(2);
endmodule
