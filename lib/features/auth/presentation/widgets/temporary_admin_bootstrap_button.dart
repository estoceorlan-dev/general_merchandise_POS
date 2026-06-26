import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/repositories/admin_bootstrap_repository.dart';
import '../providers/auth_providers.dart';

class TemporaryAdminBootstrapButton extends ConsumerStatefulWidget {
  const TemporaryAdminBootstrapButton({super.key, required this.onCreated});

  final ValueChanged<AdminBootstrapResult> onCreated;

  @override
  ConsumerState<TemporaryAdminBootstrapButton> createState() =>
      _TemporaryAdminBootstrapButtonState();
}

class _TemporaryAdminBootstrapButtonState
    extends ConsumerState<TemporaryAdminBootstrapButton> {
  bool _isCreating = false;
  bool _wasCreated = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 430),
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.onSurface,
          minimumSize: const Size.fromHeight(44),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
          side: BorderSide(color: colorScheme.outlineVariant),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
        ),
        onPressed: _isCreating || _wasCreated ? null : _createAdminAccount,
        icon: _isCreating
            ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: colorScheme.primary,
                ),
              )
            : Icon(
                _wasCreated
                    ? Icons.verified_user_outlined
                    : Icons.admin_panel_settings_outlined,
              ),
        label: Text(
          _wasCreated ? 'Temporary admin ready' : 'Create temporary admin',
        ),
      ),
    );
  }

  Future<void> _createAdminAccount() async {
    setState(() {
      _isCreating = true;
    });

    try {
      final result = await ref
          .read(createTemporaryAdminAccountUseCaseProvider)
          .call();
      if (!mounted) {
        return;
      }
      setState(() {
        _wasCreated = true;
      });
      widget.onCreated(result);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${result.displayName} admin account is ready.'),
        ),
      );
    } on AdminBootstrapException catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to create the temporary admin account.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isCreating = false;
        });
      }
    }
  }
}
