requires 'perl', '5.008001';
requires 'Mojolicious', '6.20';
requires 'Time::Moment', '0.38';
requires 'Time::y2038', '20100403';

on 'configure' => sub {
    requires 'Module::Build::Tiny', '0.039';
};

on 'test' => sub {
    requires 'Test::More', '0.98';
};
