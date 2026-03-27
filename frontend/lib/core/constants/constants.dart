const String newsAPIBaseURL = 'https://newsapi.org/v2';
const String newsAPIKey = String.fromEnvironment('NEWS_API_KEY');
const bool enableAnonymousAuth =
    bool.fromEnvironment('ENABLE_ANONYMOUS_AUTH', defaultValue: false);
const String countryQuery = 'us';
const String categoryQuery = 'general';
const String kDefaultImage = 'https://placehold.co/600x400/png?text=News';
