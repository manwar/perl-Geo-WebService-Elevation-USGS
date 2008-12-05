use strict;
use warnings;

use Test::More;

_skip_it(eval {require Geo::WebService::Elevation::USGS},
    'Unable to load Geo::WebService::Elevation::USGS');

_skip_it(eval {require LWP::UserAgent},
    'Unable to load LWP::UserAgent (should not happen)');

my $ele = _skip_it(eval {Geo::WebService::Elevation::USGS->new(places => 2)},
    'Unable to instantiate GEO::Elevation::USGS');

{
    my $ua = _skip_it(eval {LWP::UserAgent->new()},
	'Unable to instantiate LWP::UserAgent (should not happen)');

    my $pxy = _skip_it(eval {$ele->get('proxy')},
	'Unable to retrieve proxy setting');

    my $rslt = _skip_it(eval {$ua->get($pxy)},
	'Unable to execute GET (should not happen)');

    _skip_it($rslt->is_success(),
	"Unable to access $pxy");
}

plan ('no_plan');

my $rslt = eval {$ele->getElevation(38.898748, -77.037684)};
ok($rslt, 'getElevation returned a result');
is(ref $rslt, 'HASH', 'getElevation returned a hash');
is($rslt->{Data_ID}, 'NED.CONUS_NED_13E', 'Data came from NED.CONUS_NED_13E');
is($rslt->{Units}, 'FEET', 'Elevation is in feet');
is($rslt->{Elevation}, '54.70', 'Elevation is 54.70');
$rslt = eval {$ele->getElevation(38.898748, -77.037684, undef, 1)};
is($rslt, '54.70', 'getElevation (only) returned 54.70');
$rslt = eval {$ele->elevation(38.898748, -77.037684)};
is(ref $rslt, 'ARRAY', 'elevation() returns an array');
cmp_ok(eval{@$rslt}, '==', 1, 'elevation() returned a single result');
is(ref ($rslt->[0]), 'HASH', 'elevation\'s only result was a hash');
is($rslt->[0]{Data_ID}, 'NED.CONUS_NED_13E',
    'Data came from NED.CONUS_NED_13E');
is($rslt->[0]{Units}, 'FEET', 'Elevation is in feet');
is($rslt->[0]{Elevation}, '54.70', 'Elevation is 54.70');
$rslt = eval {
    $ele->getElevation(38.898748, -77.037684, 'SRTM.SA_3_ELEVATION', 1)};
ok(!$@, 'getElevation does not fail when data has bad extent');
ok(!$ele->is_valid($rslt->{Elevation}),
    'getElevation does not return a valid elevation when given a bad extent');
$ele->set(source => []);
is(ref ($ele->get('source')), 'ARRAY', 'Source can be set to an array ref');
$rslt = eval {$ele->elevation(38.898748, -77.037684)};
is(ref $rslt, 'ARRAY', 'elevation() still returns an array');
cmp_ok(eval{@$rslt}, '>', 1, 'elevation() returned multiple results');
ok(!(grep ref $_ ne 'HASH', @$rslt), 'elevation\'s results are all hashes');
$rslt = {map {$_->{Data_ID} => $_} @$rslt};
ok($rslt->{'NED.CONUS_NED_13E'}, 'We have results from NED.CONUS_NED_13E');
is($rslt->{'NED.CONUS_NED_13E'}{Units}, 'FEET', 'Elevation is in feet');
is($rslt->{'NED.CONUS_NED_13E'}{Elevation}, '54.70', 'Elevation is 54.70');
$ele->set(source => {});
is(ref ($ele->get('source')), 'HASH', 'Source can be set to a hash ref');
$rslt = eval {$ele->elevation(38.898748, -77.037684)};
is(ref $rslt, 'ARRAY', 'elevation() still returns an array');
cmp_ok(eval{@$rslt}, '>', 1, 'elevation() returned multiple results');
ok(!(grep ref $_ ne 'HASH', @$rslt), 'elevation\'s results are all hashes');
$rslt = {map {$_->{Data_ID} => $_} @$rslt};
ok($rslt->{'NED.CONUS_NED_13E'}, 'We have results from NED.CONUS_NED_13E');
is($rslt->{'NED.CONUS_NED_13E'}{Units}, 'FEET', 'Elevation is in feet');
is($rslt->{'NED.CONUS_NED_13E'}{Elevation}, '54.70', 'Elevation is 54.70');
$ele->set(
    source => ['NED.CONUS_NED_13E', 'NED.CONUS_NED'],
    use_all_limit => 5,
);
$rslt = eval {$ele->elevation(38.898748, -77.037684)};
is(ref $rslt, 'ARRAY', 'elevation() still returns an array');
cmp_ok(eval{@$rslt}, '==', 2, 'elevation() returned two results');
ok(!(grep ref $_ ne 'HASH', @$rslt), 'elevation\'s results are all hashes');
$rslt = {map {$_->{Data_ID} => $_} @$rslt};
ok($rslt->{'NED.CONUS_NED_13E'}, 'We have results from NED.CONUS_NED_13E');
is($rslt->{'NED.CONUS_NED_13E'}{Units}, 'FEET', 'Elevation is in feet');
is($rslt->{'NED.CONUS_NED_13E'}{Elevation}, '54.70', 'Elevation is 54.70');

$ele->set(
    source => ['NED.CONUS_NED_13E', 'NED.CONUS_NED', 'SRTM.SA_3_ELEVATION'],
    use_all_limit => 0,
);
$rslt = eval {$ele->elevation(38.898748, -77.037684)};
is(ref $rslt, 'ARRAY', 'elevation() still returns an array');
cmp_ok(eval{@$rslt}, '==', 3, 'elevation() returned three results');
ok(!(grep ref $_ ne 'HASH', @$rslt), 'elevation\'s results are all hashes');
$rslt = {map {$_->{Data_ID} => $_} @$rslt};
ok($rslt->{'NED.CONUS_NED_13E'}, 'We have results from NED.CONUS_NED_13E');
is($rslt->{'NED.CONUS_NED_13E'}{Units}, 'FEET', 'Elevation is in feet');
is($rslt->{'NED.CONUS_NED_13E'}{Elevation}, '54.70', 'Elevation is 54.70');
$rslt = eval {$ele->elevation(38.898748, -77.037684, 1)};
is(ref $rslt, 'ARRAY', 'elevation(valid) still returns an array');
cmp_ok(eval{@$rslt}, '==', 2, 'elevation(valid) returned two results')
    or warn "\$@ = $@";
ok(!(grep ref $_ ne 'HASH', @$rslt), 'elevation\'s results are all hashes');
$rslt = {map {$_->{Data_ID} => $_} @$rslt};
ok($rslt->{'NED.CONUS_NED_13E'}, 'We have results from NED.CONUS_NED_13E');
is($rslt->{'NED.CONUS_NED_13E'}{Units}, 'FEET', 'Elevation is in feet');
is($rslt->{'NED.CONUS_NED_13E'}{Elevation}, '54.70', 'Elevation is 54.70');
{
    my $msg;
    local $SIG{__WARN__} = sub {$msg = $_[0]};
    my $bogus = $ele->new();
    ok($bogus, 'Call new() as normal method');
    isnt($bogus, $ele, 'They are different objects');
    $bogus->set(
	source => ['FUBAR'],
	use_all_limit => 0,
    );
    $rslt = eval {$bogus->elevation(38.898748, -77.037684)};
    like($@, qr{^Source Data_ID FUBAR not found},
	'Expect error from getAllElevations');
    ok(!$rslt, 'Expect no results from source \'FUBAR\'');
    $bogus->set(
	use_all_limit => -1,
    );
    $rslt = eval {$bogus->elevation(38.898748, -77.037684)};
    like($@, qr{^ERROR: Input Source Layer was invalid\.},
	'Expect error from getElevation');
    ok(!$rslt, 'Expect no results from source \'FUBAR\'');
    $bogus->set(
	source => sub {$_[1]{Data_ID} eq 'NED.CONUS_NED_13E'},
	use_all_limit => 0,
    );
    is(ref $bogus->get('source'), 'CODE', 'Can set source to code ref');
    $rslt = eval {$bogus->elevation(38.898748, -77.037684)};
    ok($rslt, 'Got a result when using code ref as source');
    is(ref $rslt, 'ARRAY', 'Got array ref when using code ref as source');
    cmp_ok(@$rslt, '==', 1,
	'Got exactly one result when using code ref as source');
    is($rslt->[0]{Data_ID}, 'NED.CONUS_NED_13E',
	'Got correct Data_ID when using code ref as source');
    $bogus->set(source => []);
    # CAVEAT:
    # Direct manipulation of the attribute hash is UNSUPPORTED! I can't
    # think why anyone would want a public interface for {_hack_result}
    # anyway. If you do, contact me.
    $bogus->{_hack_result} = undef;
    $rslt = eval {$bogus->elevation(38.898748, -77.037684)};
    like($@, qr{^No data found in SOAP result},
	'No data error when going through getAllElevations');
    $bogus->set(croak => 0);
    $bogus->{_hack_result} = undef;
    $rslt = eval {$bogus->elevation(38.898748, -77.037684)};
    ok(!$@, 'Should not throw an error on bad result if croak is false');
    ok(!$rslt, 'Should return undef on bad result if croak is false');
    like($bogus->get('error'), qr{^No data found in SOAP result},
	'No data error when going through getAllElevations');
    $bogus->set(
	source => {'SRTM.SA_3_ELEVATION' => 1},
	use_all_limit => 5,
    );
    $rslt = eval {$bogus->elevation(38.898748, -77.037684)};
    ok(!$ele->get('error'),
	'Query of SRTM.SA_3_ELEVATION still is not an error');
    ok(!$ele->is_valid($rslt->[0]),
	'SRTM.SA_3_ELEVATION still does not return a valid elevation');

    $bogus->{_hack_result} = _get_bad_som();
    $rslt = eval {$bogus->elevation(38.898748, -77.037684)};
    ok($bogus->get('error'),
	'SOAP failures other than conversion of BAD_EXTENT are still errors.');
    $bogus->set(croak => 1);
    $bogus->{_hack_result} = _get_bad_som();
    $rslt = eval {$bogus->elevation(38.898748, -77.037684)};
    ok($@,
	'SOAP failures other than conversion are fatal with croak => 1');
    ok($bogus->get('error'),
	'SOAP failures should set {error} even if fatal');
    $bogus->set(
	source => ['FUBAR'],
	use_all_limit => 0,
	croak => 0,
    );
    $rslt = eval {$bogus->elevation(38.898748, -77.037684)};
    like($bogus->get('error'),
####	qr{ERROR: Input Source Layer was invalid},
	qr{Source Data_ID FUBAR not found},
	'Data set FUBAR is still an error');
    $bogus->set(source => undef, croak => 1);
    $bogus->{_hack_result} = undef;
    $rslt = eval {$bogus->elevation(38.898748, -77.037684)};
    like($@, qr{^No data found in SOAP result},
	'No data error when going through getElevations');
    $bogus->set(croak => 0);
    $bogus->{_hack_result} = undef;
    $rslt = eval {$bogus->elevation(38.898748, -77.037684)};
    ok(!$@, 'Should not throw an error on bad result if croak is false');
    ok(!$rslt, 'Should return undef on bad result if croak is false');
    like($bogus->get('error'), qr{^No data found in SOAP result},
	'No data error when going through getElevation');
    $bogus->{_hack_result} = {};
    $rslt = eval {$bogus->elevation(38.898748, -77.037684)};
    ok(!$@, 'Should not throw an error on bad result if croak is false');
    like($bogus->get('error'), qr{^Elevation result is missing tag},
	'Missing tag error when going through getElevation');
    $bogus->{_hack_result} = {USGS_Elevation_Web_Service_Query => []};
    $rslt = eval {$bogus->elevation(38.898748, -77.037684)};
    ok(!$@, 'Should not throw an error on bad result if croak is false');
    like($bogus->get('error'), qr{^Elevation result is missing tag},
	'Missing tag error when going through getElevation');
    $bogus->{_hack_result} = {
	USGS_Elevation_Web_Service_Query => {
	    Elevation_Query => 'Something bad happened',
	},
    };
    $rslt = eval {$bogus->elevation(38.898748, -77.037684)};
    ok(!$@, 'Should not throw an error on bad result if croak is false');
    like($bogus->get('error'), qr{^Something bad happened},
	'Missing data error when going through getElevation');
    $bogus->set(proxy => $bogus->get('proxy') . '_xyzzy');
    $rslt = eval {$bogus->elevation(38.898748, -77.037684)};
    ok(!$@, 'Should not throw an error on bad proxy if croak is false');
    like($bogus->get('error'), qr{^404\b},
	'SOAP error when going through getElevation');
    $bogus->set(source => []);
    $rslt = eval {$bogus->elevation(38.898748, -77.037684)};
    ok(!$@, 'Should not throw an error on bad proxy if croak is false');
    like($bogus->get('error'), qr{^404\b},
	'SOAP error when going through getAllElevations');
    $bogus->set(croak => 1);
    $rslt = eval {$bogus->elevation(38.898748, -77.037684)};
    ok(($msg = $@), 'Should throw an error on bad proxy if croak is true');
    like($msg, qr{^404\b},
	'SOAP error when going through getAllElevations');

}

$ele->set(
    croak => 1,
    source => undef,
    units => 'METERS'
);
$rslt = eval {$ele->getElevation(38.898748, -77.037684)};
ok($rslt, 'getElevation again returned a result');
is(ref $rslt, 'HASH', 'getElevation again returned a hash');
is($rslt->{Data_ID}, 'NED.CONUS_NED_13E', 'Data again came from NED.CONUS_NED_13E');
is($rslt->{Units}, 'METERS', 'Elevation is in meters');
is($rslt->{Elevation}, '16.67', 'Elevation is 16.67');
$rslt = eval {$ele->getElevation(38.898748, -77.037684, undef, 1)};
is($rslt, '16.67', 'getElevation (only) returned 16.67');
$rslt = eval {[$ele->elevation(38.898748, -77.037684)]};
is(ref $rslt, 'ARRAY', 'elevation() returns an array in list context');
cmp_ok(eval{@$rslt}, '==', 1, 'elevation() returned a single result');
is(ref ($rslt->[0]), 'HASH', 'elevation\'s only result was a hash');
is($rslt->[0]{Data_ID}, 'NED.CONUS_NED_13E',
    'Data came from NED.CONUS_NED_13E');
is($rslt->[0]{Units}, 'METERS', 'Elevation is in meters');
is($rslt->[0]{Elevation}, '16.67', 'Elevation is 16.67');
eval {$ele->set(source => \*STDOUT)};
like($@, qr{^Attribute source may not be a GLOB ref},
    'Can not set source as a glob ref');
$ele->{source} = \*STDOUT;	# Bypass validation
$rslt = eval {[$ele->elevation(38.898748, -77.037684)]};
like($@, qr{^Source GLOB ref not understood},
    'Bogus source reference gets caught in use');
$ele->set(source => qr{^NED\.CONUS_NED}i);
is(ref $ele->get('source'), 'Regexp', 'Can set source as a regexp ref');
$rslt = eval {[$ele->elevation(38.898748, -77.037684)]};
is(ref $rslt, 'ARRAY', 'Get an array back from regexp source');
cmp_ok(scalar @$rslt, '>=', 2, 'Should have at least two results');
$rslt = {map {$_->{Data_ID} => $_} @$rslt};
ok($rslt->{'NED.CONUS_NED_13E'}, 'We have results from NED.CONUS_NED_13E');
is($rslt->{'NED.CONUS_NED_13E'}{Units}, 'METERS', 'Elevation is in meters');
is($rslt->{'NED.CONUS_NED_13E'}{Elevation}, '16.67', 'Elevation is 16.67');



my $gp = {};
bless $gp, 'Geo::Point';
$ele->set(source => {'NED.CONUS_NED_13E' => 1});
is(ref $ele->get('source'), 'HASH', 'Can set source as a hash');
$rslt = eval {$ele->elevation($gp)};
is(ref $rslt, 'ARRAY',
    'elevation(Geo::Point) returns an array from getAllElevations');
cmp_ok(eval{@$rslt}, '==', 1, 'elevation(Geo::Point) returned a single result');
is(ref ($rslt->[0]), 'HASH', 'elevation\'s only result was a hash');
is($rslt->[0]{Data_ID}, 'NED.CONUS_NED_13E',
    'Data came from NED.CONUS_NED_13E');
is($rslt->[0]{Units}, 'METERS', 'Elevation is in meters');
is($rslt->[0]{Elevation}, '16.67', 'Elevation is 16.67');
$ele->set(use_all_limit => -1);	# Force iteration.
$rslt = eval {$ele->elevation($gp)};
is(ref $rslt, 'ARRAY',
    'elevation(Geo::Point) returns an array from getElevation');
$gp = {};
bless $gp, 'GPS::Point';
$ele->set(use_all_limit => 0);	# Force getAllElevations
$rslt = eval {$ele->elevation($gp)};
is(ref $rslt, 'ARRAY',
    'elevation(GPS::Point) returns an array from getAllElevations');
cmp_ok(eval{@$rslt}, '==', 1, 'elevation(GPS::Point) returned a single result');
is(ref ($rslt->[0]), 'HASH', 'elevation\'s only result was a hash');
is($rslt->[0]{Data_ID}, 'NED.CONUS_NED_13E',
    'Data came from NED.CONUS_NED_13E');
is($rslt->[0]{Units}, 'METERS', 'Elevation is in meters');
is($rslt->[0]{Elevation}, '16.67', 'Elevation is 16.67');

sub _skip_it {
    my ($check, $reason) = @_;
    unless ($check) {
	plan (skip_all => $reason);
	exit;
    }
    $check;
}

sub Geo::Point::latlong {
    (38.898748, -77.037684)
}

sub GPS::Point::latlon {
    (38.898748, -77.037684)
}

my $VAR1;
sub _get_bad_som {
    $VAR1 ||= bless( {
                 '_content' => [
                                 'soap:Envelope',
                                 {
                                   'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
                                   'xmlns:xsd' => 'http://www.w3.org/2001/XMLSchema',
                                   'xmlns:soap' => 'http://schemas.xmlsoap.org/soap/envelope/'
                                 },
                                 [
                                   [
                                     'soap:Body',
                                     {},
                                     [
                                       [
                                         'soap:Fault',
                                         {},
                                         [
                                           [
                                             'faultcode',
                                             {},
                                             'soap:Server',
                                             undef,
                                             'soap:Server',
                                             'faultcode',
                                             {}
                                           ],
                                           [
                                             'faultstring',
                                             {},
                                             'System.Web.Services.Protocols.SoapException: Server was unable to process request. ---> Bogus error injected into system to test error handling.',
                                             undef,
                                             'System.Web.Services.Protocols.SoapException: Server was unable to process request. ---> Bogus error injected into system to test error handling.',
                                             'faultstring',
                                             {}
                                           ],
                                           [
                                             'detail',
                                             {},
                                             '',
                                             undef,
                                             '',
                                             'detail',
                                             {}
                                           ]
                                         ],
                                         undef,
                                         {
                                           'detail' => '',
                                           'faultcode' => 'soap:Server',
                                           'faultstring' => 'System.Web.Services.Protocols.SoapException: Server was unable to process request. ---> Bogus error injected into system to test error handling.',
                                         },
                                         '{http://schemas.xmlsoap.org/soap/envelope/}Fault',
                                         {}
                                       ]
                                     ],
                                     undef,
                                     {
                                       'Fault' => $VAR1->{'_content'}[2][0][2][0][4]
                                     },
                                     '{http://schemas.xmlsoap.org/soap/envelope/}Body',
                                     {}
                                   ]
                                 ],
                                 undef,
                                 {
                                   'Body' => $VAR1->{'_content'}[2][0][4]
                                 },
                                 '{http://schemas.xmlsoap.org/soap/envelope/}Envelope',
                                 {}
                               ],
                 '_context' => bless( {
                                        '_on_nonserialized' => sub { "DUMMY" },
                                        '_deserializer' => bless( {
                                                                    '_ids' => $VAR1->{'_content'},
                                                                    '_xmlschemas' => {
                                                                                       'http://www.w3.org/2003/05/soap-encoding' => 'SOAP::Lite::Deserializer::XMLSchemaSOAP1_2',
                                                                                       'http://xml.apache.org/xml-soap' => 'SOAP::XMLSchemaApacheSOAP::Deserializer',
                                                                                       'http://www.w3.org/2001/XMLSchema' => 'SOAP::Lite::Deserializer::XMLSchema2001',
                                                                                       'http://www.w3.org/1999/XMLSchema' => 'SOAP::Lite::Deserializer::XMLSchema1999',
                                                                                       'http://schemas.xmlsoap.org/soap/encoding/' => 'SOAP::Lite::Deserializer::XMLSchemaSOAP1_1'
                                                                                     },
                                                                    '_context' => $VAR1->{'_context'},
                                                                    '_hrefs' => {},
                                                                    '_parser' => bless( {
                                                                                          '_done' => $VAR1->{'_content'},
                                                                                          '_values' => undef,
                                                                                          '_parser' => bless( {
                                                                                                                'Non_Expat_Options' => {
                                                                                                                                         'NoLWP' => 1,
                                                                                                                                         'Non_Expat_Options' => 1,
                                                                                                                                         '_HNDL_TYPES' => 1,
                                                                                                                                         'Handlers' => 1,
                                                                                                                                         'Style' => 1
                                                                                                                                       },
                                                                                                                'Pkg' => 'SOAP::Parser',
                                                                                                                'Handlers' => {
                                                                                                                                'End' => undef,
                                                                                                                                'Final' => undef,
                                                                                                                                'Char' => undef,
                                                                                                                                'Start' => undef,
                                                                                                                                'ExternEnt' => undef
                                                                                                                              },
                                                                                                                '_HNDL_TYPES' => {
                                                                                                                                   'CdataEnd' => sub { "DUMMY" },
                                                                                                                                   'Start' => sub { "DUMMY" },
                                                                                                                                   'Entity' => sub { "DUMMY" },
                                                                                                                                   'ExternEntFin' => sub { "DUMMY" },
                                                                                                                                   'End' => sub { "DUMMY" },
                                                                                                                                   'Final' => 1,
                                                                                                                                   'Doctype' => sub { "DUMMY" },
                                                                                                                                   'Char' => sub { "DUMMY" },
                                                                                                                                   'Init' => 1,
                                                                                                                                   'XMLDecl' => sub { "DUMMY" },
                                                                                                                                   'Default' => sub { "DUMMY" },
                                                                                                                                   'CdataStart' => sub { "DUMMY" },
                                                                                                                                   'Comment' => sub { "DUMMY" },
                                                                                                                                   'Unparsed' => sub { "DUMMY" },
                                                                                                                                   'ExternEnt' => sub { "DUMMY" },
                                                                                                                                   'Element' => sub { "DUMMY" },
                                                                                                                                   'Attlist' => sub { "DUMMY" },
                                                                                                                                   'DoctypeFin' => sub { "DUMMY" },
                                                                                                                                   'Notation' => sub { "DUMMY" },
                                                                                                                                   'Proc' => sub { "DUMMY" }
                                                                                                                                 }
                                                                                                              }, 'XML::Parser' )
                                                                                        }, 'SOAP::Parser' )
                                                                  }, 'SOAP::Deserializer' ),
                                        '_autoresult' => 0,
                                        '_transport' => bless( {
                                                                 '_proxy' => bless( {
                                                                                      '_status' => '500 Internal Server Error',
                                                                                      '_message' => 'Internal Server Error',
                                                                                      'requests_redirectable' => [
                                                                                                                   'GET',
                                                                                                                   'HEAD'
                                                                                                                 ],
                                                                                      'timeout' => 30,
                                                                                      '_is_success' => '',
                                                                                      'max_redirect' => 7,
                                                                                      '_http_response' => bless( {
                                                                                                                   '_protocol' => 'HTTP/1.1',
                                                                                                                   '_content' => '<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><soap:Body><soap:Fault><faultcode>soap:Server</faultcode><faultstring>System.Web.Services.Protocols.SoapException: Server was unable to process request. ---&gt; Bogus error injected into system to test error handling.</faultstring><detail /></soap:Fault></soap:Body></soap:Envelope>',
                                                                                                                   '_rc' => 500,
                                                                                                                   '_headers' => bless( {
                                                                                                                                          'x-powered-by' => 'ASP.NET',
                                                                                                                                          'client-response-num' => 1,
                                                                                                                                          'cache-control' => 'private',
                                                                                                                                          'date' => 'Wed, 03 Dec 2008 18:05:22 GMT',
                                                                                                                                          'client-peer' => '152.61.128.16:80',
                                                                                                                                          'content-length' => '1272',
                                                                                                                                          'x-aspnet-version' => '2.0.50727',
                                                                                                                                          'client-date' => 'Wed, 03 Dec 2008 18:05:21 GMT',
                                                                                                                                          'content-type' => 'text/xml; charset=utf-8',
                                                                                                                                          'server' => 'Microsoft-IIS/6.0'
                                                                                                                                        }, 'HTTP::Headers' ),
                                                                                                                   '_msg' => 'Internal Server Error',
                                                                                                                   'handlers' => {
                                                                                                                                   'response_data' => [
                                                                                                                                                        {
                                                                                                                                                          'callback' => sub { "DUMMY" }
                                                                                                                                                        }
                                                                                                                                                      ]
                                                                                                                                 },
                                                                                                                   '_request' => bless( {
                                                                                                                                          '_protocol' => 'HTTP/1.1',
                                                                                                                                          '_content' => '<?xml version="1.0" encoding="UTF-8"?><soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" soap:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"><soap:Body><getElevation xmlns="http://gisdata.usgs.gov/XMLWebServices2/"><X_Value xsi:type="xsd:string">-90</X_Value><Y_Value xsi:type="xsd:string">40</Y_Value><Source_Layer xsi:type="xsd:string">SRTM.C_US_1</Source_Layer><Elevation_Units xsi:type="xsd:string">FEET</Elevation_Units><Elevation_Only xsi:type="xsd:string">false</Elevation_Only></getElevation></soap:Body></soap:Envelope>',
                                                                                                                                          '_uri' => bless( do{\(my $o = 'http://gisdata.usgs.gov/xmlwebservices2/elevation_service.asmx')}, 'URI::http' ),
                                                                                                                                          '_headers' => bless( {
                                                                                                                                                                 'user-agent' => 'SOAP::Lite/Perl/0.710.08',
                                                                                                                                                                 'soapaction' => 'http://gisdata.usgs.gov/XMLWebServices2/getElevation',
                                                                                                                                                                 'content-type' => 'text/xml; charset=utf-8',
                                                                                                                                                                 'accept' => [
                                                                                                                                                                               'text/xml',
                                                                                                                                                                               'multipart/*',
                                                                                                                                                                               'application/soap'
                                                                                                                                                                             ],
                                                                                                                                                                 'content-length' => 715
                                                                                                                                                               }, 'HTTP::Headers' ),
                                                                                                                                          '_method' => 'POST',
                                                                                                                                          '_uri_canonical' => $VAR1->{'_context'}{'_transport'}{'_proxy'}{'_http_response'}{'_request'}{'_uri'}
                                                                                                                                        }, 'HTTP::Request' )
                                                                                                                 }, 'HTTP::Response' ),
                                                                                      '_endpoint' => 'http://gisdata.usgs.gov/xmlwebservices2/elevation_service.asmx',
                                                                                      'show_progress' => undef,
                                                                                      'protocols_forbidden' => undef,
                                                                                      'no_proxy' => [],
                                                                                      'handlers' => {
                                                                                                      'response_header' => bless( [
                                                                                                                                    {
                                                                                                                                      'owner' => 'LWP::UserAgent::parse_head',
                                                                                                                                      'callback' => sub { "DUMMY" },
                                                                                                                                      'm_media_type' => 'html',
                                                                                                                                      'line' => '/usr/local/lib/perl5/site_perl/5.10.0/LWP/UserAgent.pm:629'
                                                                                                                                    }
                                                                                                                                  ], 'HTTP::Config' )
                                                                                                    },
                                                                                      '_options' => {
                                                                                                      'is_compress' => ''
                                                                                                    },
                                                                                      'protocols_allowed' => undef,
                                                                                      'use_eval' => 1,
                                                                                      '_http_request' => bless( {
                                                                                                                  '_content' => '',
                                                                                                                  '_uri' => undef,
                                                                                                                  '_headers' => bless( {}, 'HTTP::Headers' ),
                                                                                                                  '_method' => undef
                                                                                                                }, 'HTTP::Request' ),
                                                                                      '_code' => '500',
                                                                                      'def_headers' => bless( {
                                                                                                                'user-agent' => 'SOAP::Lite/Perl/0.710.08'
                                                                                                              }, 'HTTP::Headers' ),
                                                                                      'proxy' => {},
                                                                                      'max_size' => undef
                                                                                    }, 'SOAP::Transport::HTTP::Client' )
                                                               }, 'SOAP::Transport' ),
                                        '_serializer' => bless( {
                                                                  '_typelookup' => {
                                                                                     'int' => [
                                                                                                20,
                                                                                                sub { "DUMMY" },
                                                                                                'as_int'
                                                                                              ],
                                                                                     'time' => [
                                                                                                 70,
                                                                                                 sub { "DUMMY" },
                                                                                                 'as_time'
                                                                                               ],
                                                                                     'date' => [
                                                                                                 60,
                                                                                                 sub { "DUMMY" },
                                                                                                 'as_date'
                                                                                               ],
                                                                                     'gYear' => [
                                                                                                  45,
                                                                                                  sub { "DUMMY" },
                                                                                                  'as_gYear'
                                                                                                ],
                                                                                     'string' => [
                                                                                                   100,
                                                                                                   sub { "DUMMY" },
                                                                                                   'as_string'
                                                                                                 ],
                                                                                     'dateTime' => [
                                                                                                     75,
                                                                                                     sub { "DUMMY" },
                                                                                                     'as_dateTime'
                                                                                                   ],
                                                                                     'boolean' => [
                                                                                                    90,
                                                                                                    sub { "DUMMY" },
                                                                                                    'as_boolean'
                                                                                                  ],
                                                                                     'float' => [
                                                                                                  30,
                                                                                                  sub { "DUMMY" },
                                                                                                  'as_float'
                                                                                                ],
                                                                                     'anyURI' => [
                                                                                                   95,
                                                                                                   sub { "DUMMY" },
                                                                                                   'as_anyURI'
                                                                                                 ],
                                                                                     'long' => [
                                                                                                 25,
                                                                                                 sub { "DUMMY" },
                                                                                                 'as_long'
                                                                                               ],
                                                                                     'gDay' => [
                                                                                                 40,
                                                                                                 sub { "DUMMY" },
                                                                                                 'as_gDay'
                                                                                               ],
                                                                                     'gMonthDay' => [
                                                                                                      50,
                                                                                                      sub { "DUMMY" },
                                                                                                      'as_gMonthDay'
                                                                                                    ],
                                                                                     'gYearMonth' => [
                                                                                                       55,
                                                                                                       sub { "DUMMY" },
                                                                                                       'as_gYearMonth'
                                                                                                     ],
                                                                                     'duration' => [
                                                                                                     80,
                                                                                                     sub { "DUMMY" },
                                                                                                     'as_duration'
                                                                                                   ],
                                                                                     'base64Binary' => [
                                                                                                         10,
                                                                                                         sub { "DUMMY" },
                                                                                                         'as_base64Binary'
                                                                                                       ],
                                                                                     'zerostring' => [
                                                                                                       12,
                                                                                                       sub { "DUMMY" },
                                                                                                       'as_string'
                                                                                                     ],
                                                                                     'gMonth' => [
                                                                                                   35,
                                                                                                   sub { "DUMMY" },
                                                                                                   'as_gMonth'
                                                                                                 ]
                                                                                   },
                                                                  '_encodingStyle' => 'http://schemas.xmlsoap.org/soap/encoding/',
                                                                  '_objectstack' => {},
                                                                  '_level' => 0,
                                                                  '_context' => $VAR1->{'_context'},
                                                                  '_signature' => [
                                                                                    'X_Valuestring',
                                                                                    'Y_Valuestring',
                                                                                    'Source_Layerstring',
                                                                                    'Elevation_Unitsstring',
                                                                                    'Elevation_Onlystring'
                                                                                  ],
                                                                  '_soapversion' => '1.1',
                                                                  '_maptype' => {},
                                                                  '_use_default_ns' => 1,
                                                                  '_namespaces' => {
                                                                                     'http://www.w3.org/2001/XMLSchema' => 'xsd',
                                                                                     'http://schemas.xmlsoap.org/soap/encoding/' => 'soapenc',
                                                                                     'http://www.w3.org/2001/XMLSchema-instance' => 'xsi',
                                                                                     'http://schemas.xmlsoap.org/soap/envelope/' => 'soap'
                                                                                   },
                                                                  '_seen' => {
                                                                               '9556512' => {
                                                                                              'recursive' => 0,
                                                                                              'count' => 1,
                                                                                              'value' => bless( {
                                                                                                                  '_name' => 'Y_Value',
                                                                                                                  '_type' => 'string',
                                                                                                                  '_signature' => [
                                                                                                                                    'Y_Valuestring'
                                                                                                                                  ],
                                                                                                                  '_value' => [
                                                                                                                                '40'
                                                                                                                              ],
                                                                                                                  '_attr' => {}
                                                                                                                }, 'SOAP::Data' ),
                                                                                              'multiref' => ''
                                                                                            },
                                                                               '9572032' => {
                                                                                              'recursive' => 0,
                                                                                              'count' => 1,
                                                                                              'value' => bless( {
                                                                                                                  '_name' => 'getElevation',
                                                                                                                  '_signature' => [
                                                                                                                                    'getElevation'
                                                                                                                                  ],
                                                                                                                  '_value' => [
                                                                                                                                \bless( {
                                                                                                                                           '_name' => undef,
                                                                                                                                           '_signature' => $VAR1->{'_context'}{'_serializer'}{'_signature'},
                                                                                                                                           '_value' => [
                                                                                                                                                         bless( {
                                                                                                                                                                  '_name' => 'X_Value',
                                                                                                                                                                  '_type' => 'string',
                                                                                                                                                                  '_signature' => [
                                                                                                                                                                                    'X_Valuestring'
                                                                                                                                                                                  ],
                                                                                                                                                                  '_value' => [
                                                                                                                                                                                '-90'
                                                                                                                                                                              ],
                                                                                                                                                                  '_attr' => {}
                                                                                                                                                                }, 'SOAP::Data' ),
                                                                                                                                                         $VAR1->{'_context'}{'_serializer'}{'_seen'}{'9556512'}{'value'},
                                                                                                                                                         bless( {
                                                                                                                                                                  '_name' => 'Source_Layer',
                                                                                                                                                                  '_type' => 'string',
                                                                                                                                                                  '_signature' => [
                                                                                                                                                                                    'Source_Layerstring'
                                                                                                                                                                                  ],
                                                                                                                                                                  '_value' => [
                                                                                                                                                                                'SRTM.C_US_1'
                                                                                                                                                                              ],
                                                                                                                                                                  '_attr' => {}
                                                                                                                                                                }, 'SOAP::Data' ),
                                                                                                                                                         bless( {
                                                                                                                                                                  '_name' => 'Elevation_Units',
                                                                                                                                                                  '_type' => 'string',
                                                                                                                                                                  '_signature' => [
                                                                                                                                                                                    'Elevation_Unitsstring'
                                                                                                                                                                                  ],
                                                                                                                                                                  '_value' => [
                                                                                                                                                                                'FEET'
                                                                                                                                                                              ],
                                                                                                                                                                  '_attr' => {}
                                                                                                                                                                }, 'SOAP::Data' ),
                                                                                                                                                         bless( {
                                                                                                                                                                  '_name' => 'Elevation_Only',
                                                                                                                                                                  '_type' => 'string',
                                                                                                                                                                  '_signature' => [
                                                                                                                                                                                    'Elevation_Onlystring'
                                                                                                                                                                                  ],
                                                                                                                                                                  '_value' => [
                                                                                                                                                                                'false'
                                                                                                                                                                              ],
                                                                                                                                                                  '_attr' => {}
                                                                                                                                                                }, 'SOAP::Data' )
                                                                                                                                                       ],
                                                                                                                                           '_attr' => {}
                                                                                                                                         }, 'SOAP::Data' )
                                                                                                                              ],
                                                                                                                  '_attr' => {
                                                                                                                               'xmlns' => 'http://gisdata.usgs.gov/XMLWebServices2/'
                                                                                                                             }
                                                                                                                }, 'SOAP::Data' ),
                                                                                              'multiref' => ''
                                                                                            },
                                                                               '2678224' => {
                                                                                              'recursive' => 0,
                                                                                              'count' => 1,
                                                                                              'value' => \$VAR1->{'_context'}{'_serializer'}{'_seen'}{'9572032'}{'value'},
                                                                                              'multiref' => ''
                                                                                            },
                                                                               '9572928' => {
                                                                                              'recursive' => 0,
                                                                                              'count' => 1,
                                                                                              'value' => ${$VAR1->{'_context'}{'_serializer'}{'_seen'}{'9572032'}{'value'}{'_value'}[0]}->{'_value'}->[0],
                                                                                              'multiref' => ''
                                                                                            },
                                                                               '2678256' => {
                                                                                              'recursive' => 0,
                                                                                              'count' => 1,
                                                                                              'value' => $VAR1->{'_context'}{'_serializer'}{'_seen'}{'9572032'}{'value'}{'_value'}[0],
                                                                                              'multiref' => ''
                                                                                            },
                                                                               '9556864' => {
                                                                                              'recursive' => 0,
                                                                                              'count' => 1,
                                                                                              'value' => ${$VAR1->{'_context'}{'_serializer'}{'_seen'}{'9572032'}{'value'}{'_value'}[0]}->{'_value'}->[3],
                                                                                              'multiref' => ''
                                                                                            },
                                                                               '9558128' => {
                                                                                              'recursive' => 0,
                                                                                              'count' => 1,
                                                                                              'value' => bless( {
                                                                                                                  '_name' => 'Envelope',
                                                                                                                  '_signature' => [
                                                                                                                                    'soap:Envelope'
                                                                                                                                  ],
                                                                                                                  '_value' => [
                                                                                                                                \bless( {
                                                                                                                                           '_name' => undef,
                                                                                                                                           '_signature' => [
                                                                                                                                                             'soap:Body'
                                                                                                                                                           ],
                                                                                                                                           '_value' => [
                                                                                                                                                         bless( {
                                                                                                                                                                  '_name' => 'Body',
                                                                                                                                                                  '_signature' => [
                                                                                                                                                                                    'soap:Body'
                                                                                                                                                                                  ],
                                                                                                                                                                  '_value' => [
                                                                                                                                                                                $VAR1->{'_context'}{'_serializer'}{'_seen'}{'2678224'}{'value'}
                                                                                                                                                                              ],
                                                                                                                                                                  '_prefix' => 'soap',
                                                                                                                                                                  '_attr' => {}
                                                                                                                                                                }, 'SOAP::Data' )
                                                                                                                                                       ],
                                                                                                                                           '_attr' => {}
                                                                                                                                         }, 'SOAP::Data' )
                                                                                                                              ],
                                                                                                                  '_prefix' => 'soap',
                                                                                                                  '_attr' => {
                                                                                                                               '{http://schemas.xmlsoap.org/soap/envelope/}encodingStyle' => 'http://schemas.xmlsoap.org/soap/encoding/'
                                                                                                                             }
                                                                                                                }, 'SOAP::Data' ),
                                                                                              'multiref' => ''
                                                                                            },
                                                                               '9557776' => {
                                                                                              'recursive' => 0,
                                                                                              'count' => 1,
                                                                                              'value' => ${$VAR1->{'_context'}{'_serializer'}{'_seen'}{'9558128'}{'value'}{'_value'}[0]}->{'_value'}->[0],
                                                                                              'multiref' => ''
                                                                                            },
                                                                               '9557952' => {
                                                                                              'recursive' => 0,
                                                                                              'count' => 1,
                                                                                              'value' => ${$VAR1->{'_context'}{'_serializer'}{'_seen'}{'9558128'}{'value'}{'_value'}[0]},
                                                                                              'multiref' => ''
                                                                                            },
                                                                               '9557040' => {
                                                                                              'recursive' => 0,
                                                                                              'count' => 1,
                                                                                              'value' => ${$VAR1->{'_context'}{'_serializer'}{'_seen'}{'9572032'}{'value'}{'_value'}[0]}->{'_value'}->[4],
                                                                                              'multiref' => ''
                                                                                            },
                                                                               '9557888' => {
                                                                                              'recursive' => 0,
                                                                                              'count' => 1,
                                                                                              'value' => $VAR1->{'_context'}{'_serializer'}{'_seen'}{'9558128'}{'value'}{'_value'}[0],
                                                                                              'multiref' => ''
                                                                                            },
                                                                               '9556688' => {
                                                                                              'recursive' => 0,
                                                                                              'count' => 1,
                                                                                              'value' => ${$VAR1->{'_context'}{'_serializer'}{'_seen'}{'9572032'}{'value'}{'_value'}[0]}->{'_value'}->[2],
                                                                                              'multiref' => ''
                                                                                            },
                                                                               '9557472' => {
                                                                                              'recursive' => 0,
                                                                                              'count' => 1,
                                                                                              'value' => ${$VAR1->{'_context'}{'_serializer'}{'_seen'}{'9572032'}{'value'}{'_value'}[0]},
                                                                                              'multiref' => ''
                                                                                            }
                                                                             },
                                                                  '_attr' => $VAR1->{'_context'}{'_serializer'}{'_seen'}{'9558128'}{'value'}{'_attr'},
                                                                  '_multirefinplace' => 0,
                                                                  '_on_nonserialized' => $VAR1->{'_context'}{'_on_nonserialized'},
                                                                  '_xmlschema' => 'http://www.w3.org/2001/XMLSchema',
                                                                  '_ns_prefix' => '',
                                                                  '_readable' => 0,
                                                                  '_ns_uri' => 'http://gisdata.usgs.gov/XMLWebServices2/',
                                                                  '_encoding' => 'UTF-8',
                                                                  '_autotype' => 1
                                                                }, 'SOAP::Serializer' ),
                                        '_schema' => undef,
                                        '_packager' => bless( {
                                                                '_env_location' => '/main_envelope',
                                                                '_content_encoding' => '8bit',
                                                                '_env_id' => '<main_envelope>',
                                                                '_parts' => [],
                                                                '_persist_parts' => 0,
                                                                '_parser' => undef
                                                              }, 'SOAP::Packager::MIME' ),
                                        '_on_action' => sub { "DUMMY" },
                                        '_on_fault' => sub { "DUMMY" }
                                      }, 'SOAP::Lite' ),
                 '_current' => [
                                 $VAR1->{'_content'}
                               ]
               }, 'SOAP::SOM' );
}
