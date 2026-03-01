import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:xdeal/localization/app_localizations.dart';
import 'package:xdeal/models/ad.dart';
import 'package:xdeal/providers/user_provider.dart';
import 'package:xdeal/services/ads_service.dart';
import 'package:xdeal/services/api_client.dart';
import 'package:xdeal/services/upload_service.dart';
import 'package:xdeal/utils/app_colors.dart';
import 'package:xdeal/utils/utility_functions.dart';
import 'package:xdeal/widgets/custom_appbar.dart';

class AdManagementScreen extends StatefulWidget {
  const AdManagementScreen({super.key});

  @override
  State<AdManagementScreen> createState() => _AdManagementScreenState();
}

class _AdManagementScreenState extends State<AdManagementScreen> {
  late final AdsService _adsService = AdsService(
    ApiClient(baseUrl: 'https://xdeal.beproagency.com'),
  );
  late final UploadService _uploadService = UploadService(
    baseUrl: 'https://xdeal.beproagency.com',
  );
  final ImagePicker _picker = ImagePicker();

  bool _loading = true;
  String? _error;
  List<Ad> _ads = [];

  @override
  void initState() {
    super.initState();
    _loadAds();
  }

  Future<void> _loadAds() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final items = await _adsService.getAds(limit: 100);
      if (!mounted) return;
      setState(() => _ads = items);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openAddAdModal() async {
    final user = context.read<UserProvider>().user;
    if (user == null) return;

    final titleCtrl = TextEditingController();
    XFile? selectedImage;
    bool adding = false;

    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 16,
                  bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr('Add Ad'),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: titleCtrl,
                        decoration: InputDecoration(
                          labelText: context.tr('Ad Title'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (selectedImage != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            File(selectedImage!.path),
                            width: double.infinity,
                            height: 160,
                            fit: BoxFit.cover,
                          ),
                        ),
                      const SizedBox(height: 10),
                      OutlinedButton.icon(
                        onPressed: adding
                            ? null
                            : () async {
                                final picked = await _picker.pickImage(
                                  source: ImageSource.gallery,
                                  imageQuality: 85,
                                );
                                if (picked == null) return;
                                setModalState(() => selectedImage = picked);
                              },
                        icon: const Icon(Icons.image_outlined),
                        label: Text(context.tr('Select Ad Image')),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: adding
                                  ? null
                                  : () => Navigator.pop(context, false),
                              child: Text(context.tr('Cancel')),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: adding
                                  ? null
                                  : () async {
                                      final title = titleCtrl.text.trim();
                                      if (title.isEmpty) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              context.tr(
                                                'Please enter ad title',
                                              ),
                                            ),
                                          ),
                                        );
                                        return;
                                      }
                                      if (selectedImage == null) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              context.tr(
                                                'Please select ad image',
                                              ),
                                            ),
                                          ),
                                        );
                                        return;
                                      }

                                      setModalState(() => adding = true);
                                      final failedUploadMsg = this.context.tr(
                                        'Failed to upload image',
                                      );
                                      try {
                                        final urls = await _uploadService
                                            .uploadFiles(
                                              type: 'ads',
                                              files: [selectedImage!],
                                            );
                                        if (urls.isEmpty) {
                                          throw Exception(failedUploadMsg);
                                        }

                                        await _adsService.createAd(
                                          token: user.token,
                                          title: title,
                                          image: urls.first,
                                        );

                                        if (!mounted) return;
                                        Navigator.pop(this.context, true);
                                      } catch (e) {
                                        if (!mounted) return;
                                        ScaffoldMessenger.of(
                                          this.context,
                                        ).showSnackBar(
                                          SnackBar(content: Text('$e')),
                                        );
                                        setModalState(() => adding = false);
                                      }
                                    },
                              child: adding
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(context.tr('Save')),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    await Future<void>.delayed(const Duration(milliseconds: 220));
    titleCtrl.dispose();

    if (created == true) {
      await _loadAds();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('Ad created successfully.'))),
      );
    }
  }

  Future<void> _deleteAd(Ad ad) async {
    final user = context.read<UserProvider>().user;
    if (user == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.tr('Delete Ad?')),
        content: Text(context.tr('This action cannot be undone.')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.tr('Cancel')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.red),
            child: Text(context.tr('Delete')),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _adsService.deleteAd(token: user.token, adId: ad.id);
      await _loadAds();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.tr('Ad deleted.'))));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddAdModal,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          context.tr('Add Ad'),
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            CustomAppbar(title: 'Ad Management'),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${context.tr('Failed to load ads:')}\n$_error',
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: _loadAds,
                              child: Text(context.tr('Retry')),
                            ),
                          ],
                        ),
                      ),
                    )
                  : _ads.isEmpty
                  ? Center(child: Text(context.tr('No ads available')))
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 88),
                      itemCount: _ads.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final ad = _ads[index];
                        return Container(
                          decoration: BoxDecoration(
                            color: AppColors.greyBg,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                UtilityFunctions.resolveImageUrl(ad.image),
                                width: 64,
                                height: 64,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const SizedBox(
                                  width: 64,
                                  height: 64,
                                  child: Icon(Icons.broken_image_outlined),
                                ),
                              ),
                            ),
                            title: Text(
                              ad.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              UtilityFunctions.formatDate(ad.createdAt),
                            ),
                            trailing: IconButton(
                              onPressed: () => _deleteAd(ad),
                              icon: Icon(
                                Icons.delete_outline,
                                color: AppColors.red,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
