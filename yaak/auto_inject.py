import inspect

from yaak.inject import _DefaultFeatureProvider, bind


class AutoInject:
    """Decorator that provides parameter-based dependency injection."""

    def __init__(self, provider=None):
        self.provider = provider or _DefaultFeatureProvider

    def __call__(self, wrapped):
        """Decorator protocol"""
        if inspect.isclass(wrapped):
            # support class injection by injecting the __init__ method
            wrapped.__init__ = self._wrap(wrapped.__init__)
            return wrapped
        else:
            return self._wrap(wrapped)

    def _wrap(self, func):
        """Wrap a function so that one parameter is automatically injected
        and the other parameters should be passed to the wrapper function in
        the same order as in the wrapped function, or by keyword arguments"""
        # deal with stacked decorators: find the original function and the

        full_inspection = inspect.getfullargspec(func)
        injected_params = getattr(func, 'injected_params', {})
        injected_function = getattr(func, 'injected_function', func)

        # add the new injected parameter
        for feature in full_inspection.args:

            if self.provider.provides(feature):
                injected_params[feature] = (lambda f=feature: self.provider.get(f))
            else:
                annotation = full_inspection.annotations.get(feature)

                if annotation is not None and self.provider.provides(annotation.__name__):
                    injected_params[feature] = (lambda f=annotation.__name__: self.provider.get(f))

        # inject it
        new_func = bind(injected_function, **injected_params)
        new_func.injected_params = injected_params
        new_func.injected_function = injected_function

        return new_func
