# r10uvm143 — IO_DECL LISTING CENSUS: one row per task/function LISTING in a
# uhdm-dump, giving its vpiIODecl entries in ORDER with each io_decl name,
# vpiDirection and whether it carries a vpiExpr (a DEFAULT VALUE).
# MEASUREMENT ONLY.  This is what REFUTED the brief's "golden's Io_decls is
# SHORTER than ours" framing: golden and ours agree on every one of the 4809
# subroutine rows of SimpleUVM/default.
#   usage: awk -f iocen143.awk <uhdm-dump output>
# Dump-tree census of io_decl listings per task/function LISTING.
# Emits: <kind>\t<fullname>\t<n_io>\t<io spec list>
# io spec = name:dir:expr?  (expr? = E if the io_decl carries a |vpiExpr:)
function indent(s,  n){ n=match(s,/[^ ]/); return n-1 }
{ line[NR]=$0; ind[NR]=indent($0) }
END{
  for(i=1;i<=NR;i++){
    if(line[i] !~ /^ *\\_(task|function): /) continue
    d=ind[i]
    # must be a LISTING: next line is at d+2
    if(i>=NR || ind[i+1]!=d+2) continue
    fn=""; n=0; spec=""
    for(j=i+1;j<=NR && ind[j]>d;j++){
      if(ind[j]!=d+2) continue
      if(line[j] ~ /^ *\|vpiFullName:/){ fn=line[j]; sub(/^ *\|vpiFullName:/,"",fn) }
      if(line[j] ~ /^ *\|vpiIODecl:/){
        # value object header on the NEXT line at d+2
        k=j+1
        if(k<=NR && line[k] ~ /^ *\\_io_decl: /){
          nm=line[k]; sub(/^ *\\_io_decl: \(/,"",nm); sub(/\).*/,"",nm)
          dir="?"; ex="-"
          if(k<NR && ind[k+1]==d+4){
            for(m=k+1;m<=NR && ind[m]>d+2;m++){
              if(ind[m]!=d+4) continue
              if(line[m] ~ /^ *\|vpiDirection:/){ dir=line[m]; sub(/^ *\|vpiDirection:/,"",dir) }
              if(line[m] ~ /^ *\|vpiExpr:/){ ex="E" }
            }
          }
          n++; spec=spec (spec?",":"") nm ":" dir ":" ex
        }
      }
    }
    if(fn=="") fn="<noname>"
    kd=line[i]; sub(/^ *\\_/,"",kd); sub(/:.*/,"",kd)
    printf "%s\t%s\t%d\t%s\n", kd, fn, n, spec
  }
}
