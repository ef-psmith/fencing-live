#file:startup.pl

use lib qw(/home/engarde/lib /home/engarde/perl5/lib/perl5);

use ModPerl::Util (); #for CORE::GLOBAL::exit
  
#use Apache2::RequestRec ();
#use Apache2::RequestIO ();
#use Apache2::RequestUtil ();
  
#use Apache2::ServerRec ();
#use Apache2::ServerUtil ();
#use Apache2::Connection ();
#use Apache2::Log ();
  
#use APR::Table ();
  
use ModPerl::Registry ();

#use Engarde;
#use Engarde::DB;


#use Apache2::Const -compile => ':common';
#use APR::Const -compile => ':common';
 
1;
