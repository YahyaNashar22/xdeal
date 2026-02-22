import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:xdeal/providers/user_provider.dart';

import 'package:xdeal/services/api_client.dart';
import 'package:xdeal/services/vehicle_listing_service.dart';
import 'package:xdeal/models/vehicle_listing.dart' as model;

import 'package:xdeal/widgets/vehicle_listing.dart' as w;
import 'package:xdeal/widgets/property_listing.dart'; // keep for selectedView == 0

enum ListingFilter { none, newest, cheapest, expensive, notListed }

class ListingsViewer extends StatefulWidget {
  final int selectedView; // 0 properties, 1 vehicles
  final bool isDealerProfile;
  final bool isUploaderViewing;
  final bool onlyFavorites;
  final ListingFilter filter;

  const ListingsViewer({
    super.key,
    required this.selectedView,
    this.isDealerProfile = false,
    this.isUploaderViewing = false,
    this.onlyFavorites = false,
    this.filter = ListingFilter.newest,
  });

  @override
  State<ListingsViewer> createState() => _ListingsViewerState();
}

class _ListingsViewerState extends State<ListingsViewer> {
  final _scrollController = ScrollController();

  late final ApiClient _api;
  late final VehicleListingService _vehicleService;

  final List<model.VehicleListing> _vehicles = [];
  bool _loadingFirstPage = false;
  bool _loadingMore = false;
  bool _hasMore = true;
  int _page = 1;
  final int _limit = 10;
  String? _error;

  @override
  void initState() {
    super.initState();

    // If you already have a singleton ApiClient, use it instead.
    _api = ApiClient(baseUrl: 'http://10.0.2.2:5000');
    _vehicleService = VehicleListingService(_api);

    _scrollController.addListener(_onScroll);

    _fetchFirstPage();
  }

  @override
  void didUpdateWidget(covariant ListingsViewer oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If view/filter changes, reset and refetch
    final viewChanged = oldWidget.selectedView != widget.selectedView;
    final filterChanged = oldWidget.filter != widget.filter;
    final favChanged = oldWidget.onlyFavorites != widget.onlyFavorites;

    if (viewChanged || filterChanged || favChanged) {
      _resetAndRefetch();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_hasMore || _loadingMore || _loadingFirstPage) return;

    final position = _scrollController.position;
    // Load more when 250px near bottom
    if (position.pixels >= position.maxScrollExtent - 250) {
      _fetchMore();
    }
  }

  Future<void> _resetAndRefetch() async {
    setState(() {
      _vehicles.clear();
      _page = 1;
      _hasMore = true;
      _error = null;
    });
    await _fetchFirstPage();
  }

  // Map your UI filters to backend sort
  ({String sortBy, String sortDir, bool? isListed}) _filterToQuery() {
    switch (widget.filter) {
      case ListingFilter.newest:
        return (sortBy: "createdAt", sortDir: "desc", isListed: true);
      case ListingFilter.cheapest:
        // if your backend sorts by "price", ensure it's numeric in DB
        return (sortBy: "price", sortDir: "asc", isListed: true);
      case ListingFilter.expensive:
        return (sortBy: "price", sortDir: "desc", isListed: true);
      case ListingFilter.notListed:
        return (sortBy: "createdAt", sortDir: "desc", isListed: false);
      case ListingFilter.none:
        // default: only listed (your old behavior)
        return (sortBy: "createdAt", sortDir: "desc", isListed: true);
    }
  }

  Future<void> _fetchFirstPage() async {
    if (widget.selectedView != 1)
      return; // vehicles only in this implementation

    setState(() {
      _loadingFirstPage = true;
      _error = null;
    });

    try {
      final f = _filterToQuery();

      final items = await _vehicleService.getAll(
        page: 1,
        limit: _limit,
        isListed: f.isListed,
        sortBy: f.sortBy,
        sortDir: f.sortDir,
      );

      // Client-side favorites filtering (only if you have that data)
      final filtered = widget.onlyFavorites ? _applyFavorites(items) : items;

      setState(() {
        _vehicles
          ..clear()
          ..addAll(filtered);
        _page = 1;
        _hasMore = items.length == _limit; // heuristic
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loadingFirstPage = false);
    }
  }

  Future<void> _fetchMore() async {
    if (widget.selectedView != 1) return;

    setState(() {
      _loadingMore = true;
      _error = null;
    });

    try {
      final nextPage = _page + 1;
      final f = _filterToQuery();

      final items = await _vehicleService.getAll(
        page: nextPage,
        limit: _limit,
        isListed: f.isListed,
        sortBy: f.sortBy,
        sortDir: f.sortDir,
      );

      final filtered = widget.onlyFavorites ? _applyFavorites(items) : items;

      setState(() {
        _vehicles.addAll(filtered);
        _page = nextPage;
        _hasMore = items.length == _limit;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  // Adjust this to match your real favorite system
  List<model.VehicleListing> _applyFavorites(List<model.VehicleListing> items) {
    // Option A: if model has `isFavorite`
    // return items.where((x) => x.isFavorite == true).toList();

    // Option B: if favorites stored in a provider (recommended)
    // final favIds = context.read<FavoritesProvider>().vehicleIds;
    // return items.where((x) => favIds.contains(x.id)).toList();

    // For now: no-op (keeps behavior but won’t filter)
    return items;
  }

  @override
  Widget build(BuildContext context) {
    // Properties still using dummy widgets (you can add a PropertyListingService later)
    if (widget.selectedView == 0) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text("TODO: connect property listings service"),
        ),
      );
    }

    if (_loadingFirstPage) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Failed to load listings:\n$_error",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _fetchFirstPage,
                child: const Text("Retry"),
              ),
            ],
          ),
        ),
      );
    }

    if (_vehicles.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            'No current listings',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ),
      );
    }

    return ListView.separated(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: _vehicles.length + 1, // +1 for footer loader
      separatorBuilder: (_, __) => const SizedBox(height: 24),
      itemBuilder: (context, index) {
        if (index == _vehicles.length) {
          if (!_hasMore) return const SizedBox(height: 8);
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Center(
              child: _loadingMore
                  ? const CircularProgressIndicator()
                  : TextButton(
                      onPressed: _fetchMore,
                      child: const Text("Load more"),
                    ),
            ),
          );
        }

        final listing = _vehicles[index];

        // Your existing widget expects a Map; you should update it to accept VehicleListing.
        // If you can't, convert to map via toJson().
        return w.VehicleListing(
          vehicle: listing.toJson(),
          isDealerProfile: widget.isDealerProfile,
          isUploaderViewing: widget.isUploaderViewing,
        );
      },
    );
  }
}
