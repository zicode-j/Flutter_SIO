class ApiEndpoint {
  static const baseUrl = 'dummyjson.com';
  static const products = '/products/search';
  static const categories = '/products/categories';
  static productOfCategories(String category) => '/products/category/$category';
}