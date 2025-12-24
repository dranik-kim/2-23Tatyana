from django.db import models

from users.models import User

# Create your models here.
class ProductCategory(models.Model): # Наследование класса, интегрированый из фреймворка
    name = models.CharField(max_length=128)
    description = models.TextField(null=True, blank=True)

    def __str__(self): # Возвращает значения в заданном формате
        return self.name

class Product(models.Model):
    name = models.CharField(max_length=128)
    description = models.TextField()
    price = models.DecimalField(max_digits=6, decimal_places=2)
    quantity = models.PositiveBigIntegerField(default=0)
    image = models.ImageField(upload_to='products_images') # директория, куда будут загружаться файлы
    category = models.ForeignKey(to=ProductCategory, on_delete=models.CASCADE)

    def __str__(self):
        return f'Продукт: {self.name} | Категория: {self.category}'

class BasketQuerySet(models.QuerySet):
    def total_sum(self):
        return sum(basket.sum() for basket in self)
    
    def total_quantity(self):
        return sum(basket.quantity for basket in self)

class Basket(models.Model):
    user = models.ForeignKey(to=User, on_delete=models.CASCADE)
    products = models.ForeignKey(to=Product, on_delete=models.CASCADE)
    quantity = models.PositiveSmallIntegerField(default=0)
    created_timestamp = models.DateTimeField(auto_now_add=True) # автоматически добавляет дату и время создания записи

    objects = BasketQuerySet.as_manager()

    def __str__(self):
        return f'Корзина для {self.user.username} | Продукт: {self.products.name}'
    
    def sum(self):
        return self.products.price * self.quantity